import boto3
import os
from botocore.exceptions import NoCredentialsError
import uuid
from dotenv import load_dotenv

# Load environment variables from .env file if present
load_dotenv()

# S3 configuration
S3_BUCKET = os.environ.get('S3_BUCKET_NAME', 'ai-nutrition-tracker-images')
S3_LOCATION = f"https://{S3_BUCKET}.s3.amazonaws.com/"

# Create S3 client
s3 = boto3.client(
    's3',
    region_name=os.environ.get('AWS_REGION', 'us-east-1'),
    aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID'),
    aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY')
)

def upload_file_to_s3(file, filename=None, folder='uploads'):
    """
    Uploads a file to S3 bucket
    """
    if filename is None:
        # Generate unique filename
        ext = os.path.splitext(file.filename)[1]
        filename = f"{uuid.uuid4()}{ext}"
    
    # Add folder prefix if needed
    if folder:
        filename = f"{folder}/{filename}"
    
    try:
        s3.upload_fileobj(
            file,
            S3_BUCKET,
            filename,
            ExtraArgs={
                "ContentType": file.content_type
            }
        )
        return f"{S3_LOCATION}{filename}"
    except NoCredentialsError:
        print("No AWS credentials found")
        return None
    except Exception as e:
        print(f"Error uploading to S3: {str(e)}")
        return None

def download_file_from_s3(s3_key, local_path):
    """
    Downloads a file from S3 bucket
    """
    try:
        s3.download_file(S3_BUCKET, s3_key, local_path)
        return True
    except NoCredentialsError:
        print("No AWS credentials found")
        return False
    except Exception as e:
        print(f"Error downloading from S3: {str(e)}")
        return False