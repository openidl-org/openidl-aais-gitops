# openidl-etl-intake-processor

This processor is meant to run as a lambda in aws.
See the general readme at the top level of the project to see how to deploy

## functionality

-   reads a csv file from an s3 bucket
-   expected format is:
    -   carrier number - the identifier for the carrier (string)
    -   vin - the vin for the automobile reported (15 position string)
    -   transaction date - date this transaction is active (date)
    -   effective date - effective date of the coverage (date, optional)
    -   expiration date - date coverage expires (date, optioinsl)

Optional fields that are not provided are filled in as follows:

-   effective date is set to the transaction date
-   expiration date is set same day of next month
