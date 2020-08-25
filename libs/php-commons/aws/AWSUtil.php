<?php 

require_once __DIR__ . '/../../aws/aws-autoloader.php';
require_once __DIR__ . '/../XSSHelpers.php';
require_once __DIR__ . '/../CommonConfig.php';

use Aws\S3\S3Client;
use Aws\Exception\AwsException;
use Aws\S3\Exception\S3Exception;



class AWSUtil
{

    private $awsConfig;
    private $sdk;
    private $s3Client;
    private $s3BucketName;

    function __construct() {
        $config = new CommonConfig();
        $this->awsConfig = $config->awsSharedConfig;

        $this->sdk = new Aws\Sdk($this->awsConfig);
        // TODO: consider caching credentials

        $this->s3BucketName = $this->awsConfig['S3']['bucket'];
        $this->s3Client = $this->sdk->createS3();

    }

    function s3putObject($sanitizedFileName, $sourceFile) {
        try {
            $result = $this->s3Client->putObject([
                'Bucket' => $this->s3BucketName, // REQUIRED
                'Key' => $sanitizedFileName, // REQUIRED, the sanitized filename as well as portal path
                // 'ServerSideEncryption' => 'aws:kms', // TODO consider encryption
                'SourceFile' => $sourceFile,
                'StorageClass' => 'STANDARD'
            ]);

            return $result;
        } catch (S3Exception $e) {
            echo $e->getMessage();

            return $e;
        } catch (AwsException $e) {
            echo $e->getAwsRequestId() . "\n";
            echo $e->getAwsErrorType() . "\n";
            echo $e->getAwsErrorCode() . "\n";

            return $e;
        } catch (Exception $e) {
            echo $e->getMessage();
            return $e;
        } 
    }

    function s3getObject($sanitizedFileName, $saveAs = "") {
        try {

            if ($saveAs != "") {
                $result = $this->s3Client->getObject([
                    'Bucket' => $this->s3BucketName, // REQUIRED
                    'Key' => $sanitizedFileName, // REQUIRED
                    'SaveAs' => $saveAs
                ]);
            } else {
                $result = $this->s3Client->getObject([
                    'Bucket' => $this->s3BucketName, // REQUIRED
                    'Key' => $sanitizedFileName // REQUIRED
                ]);
            }


            return $result;
        } catch (S3Exception $e) {
            // If file DNE in S3, delete failed downlaod
            if ($e->getAwsErrorCode() == "NoSuchKey" && $saveAs != "") {
                unlink($saveAs);
            }

            return $e->getAwsErrorCode();
        } catch (AwsException $e) {
            echo $e->getAwsRequestId() . "\n";
            echo $e->getAwsErrorType() . "\n";
            echo $e->getAwsErrorCode() . "\n";

            return $e;
        } catch (Exception $e) {
            echo $e->getMessage();
            return $e;
        } 
        
    }

    function s3deleteObject($sanitizedFileName) {
        try {
            $result = $this->s3Client->deleteObject([
                'Bucket' => $this->s3BucketName, // REQUIRED
                'Key' => $sanitizedFileName // REQUIRED, the sanitized filename as well as portal path
            ]);

            return $result;
        } catch (S3Exception $e) {
            echo $e->getMessage();

            return $e;
        } catch (AwsException $e) {
            echo $e->getAwsRequestId() . "\n";
            echo $e->getAwsErrorType() . "\n";
            echo $e->getAwsErrorCode() . "\n";

            return $e;
        } catch (Exception $e) {
            echo $e->getMessage();
            return $e;
        } 
    }

    function s3registerStreamWrapper() {
        $this->s3Client->registerStreamWrapper();
    }

    function s3getBucketName() {
        return $this->s3BucketName;
    }
}
?>