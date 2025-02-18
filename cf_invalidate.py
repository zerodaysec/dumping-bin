"""cf_invalidate.py"""
import sys
import time
import boto3


# Get domain name from command line argument
DOMAIN = sys.argv[1]

# Create CloudFront client
client = boto3.client("cloudfront")

# Get all CloudFront distributions
CF_DISTS = client.list_distributions()

# Find the distribution for the given domain name
DIST_ID = None
for distribution in CF_DISTS["DistributionList"]["Items"]:
    if (
        "Items" in distribution["Aliases"]
        and distribution["Aliases"]["Items"][0] == DOMAIN
    ):
        DIST_ID = distribution["Id"]
        break

# Invalidate the path /* for the distribution
if DIST_ID:
    ts = time.time()
    resp = client.create_invalidation(
        DistributionId=DIST_ID,
        InvalidationBatch={
            "Paths": {
                "Quantity": 1,
                "Items": [
                    "/*",
                ],
            },
            # Unique string for each request for invalidation
            "CallerReference": f"invalidate_all {ts}",
        },
    )
    print(f"Invalidated path /* for distribution - {DOMAIN} - {DIST_ID}\n{resp}")
else:
    print(f"No distribution found for domain {DOMAIN}")
