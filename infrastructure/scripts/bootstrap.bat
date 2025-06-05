@echo off
REM Bootstrap script to create Terraform state backend resources for Windows
REM Run this once before using Terragrunt

echo 🚀 Bootstrapping Terraform backend for FusionResume

REM Configuration
set AWS_REGION=us-west-2
set PROJECT_NAME=fusion-resume

REM Get AWS Account ID
echo 📋 Getting AWS Account ID...
for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%i

if "%AWS_ACCOUNT_ID%"=="" (
    echo ❌ Error: Could not get AWS Account ID. Make sure AWS CLI is configured.
    echo Run: aws configure
    pause
    exit /b 1
)

echo 📋 AWS Account ID: %AWS_ACCOUNT_ID%
echo 🌍 Region: %AWS_REGION%

REM Create S3 bucket for Terraform state
set BUCKET_NAME=%PROJECT_NAME%-terraform-state-%AWS_ACCOUNT_ID%
echo 📦 Creating S3 bucket: %BUCKET_NAME%

aws s3api create-bucket --bucket %BUCKET_NAME% --region %AWS_REGION% 2>nul
if errorlevel 1 (
    echo S3 bucket already exists or creation failed
)

REM Enable versioning
echo 🔄 Enabling versioning...
aws s3api put-bucket-versioning --bucket %BUCKET_NAME% --versioning-configuration Status=Enabled

REM Enable encryption
echo 🔐 Enabling encryption...
aws s3api put-bucket-encryption --bucket %BUCKET_NAME% --server-side-encryption-configuration "{\"Rules\":[{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\":\"AES256\"}}]}"

REM Block public access
echo 🚫 Blocking public access...
aws s3api put-public-access-block --bucket %BUCKET_NAME% --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

REM Create DynamoDB table for state locking
set TABLE_NAME=%PROJECT_NAME%-terraform-locks
echo 🔒 Creating DynamoDB table: %TABLE_NAME%

aws dynamodb create-table --table-name %TABLE_NAME% --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --region %AWS_REGION% 2>nul
if errorlevel 1 (
    echo DynamoDB table already exists or creation failed
)

echo.
echo ✅ Bootstrap complete!
echo 📝 Your Terraform state will be stored in: s3://%BUCKET_NAME%
echo 🔐 State locking will use DynamoDB table: %TABLE_NAME%
echo.
echo 📋 Set your AWS Account ID environment variable:
echo    set AWS_ACCOUNT_ID=%AWS_ACCOUNT_ID%
echo.
echo 🚀 You can now run: cd infrastructure\environments\dev
echo    Then run: terragrunt apply
echo.
pause