#!/bin/bash
# Prepares SW4BAD Assignment 1 for submission

echo "Preparing SW4BAD Assignment 1 for submission..."

# Require AU ID parameter
if [ -z "$1" ]; then
    echo "Usage: ./prepare_submission.sh <your-au-id>"
    echo "Example: ./prepare_submission.sh AU778738"
    exit 1
fi

AU_ID=$1
SUBMISSION_DIR="submission_temp"
ZIP_NAME="sw4bad-mas1-${AU_ID}.zip"

echo "Cleaning solution..."
cd src/WebAPI && dotnet clean && cd ../..

echo "Creating submission structure..."
rm -rf submission/$SUBMISSION_DIR
mkdir -p submission/$SUBMISSION_DIR

# Copy files to flat structure for submission
cp -r src/WebAPI submission/$SUBMISSION_DIR/
cp database/scripts/create_database.sql submission/$SUBMISSION_DIR/
cp database/scripts/insert_data.sql submission/$SUBMISSION_DIR/
cp database/scripts/queries.sql submission/$SUBMISSION_DIR/
cp database/design/ERD.png submission/$SUBMISSION_DIR/ 2>/dev/null || true
cp database/design/design_reasoning.md submission/$SUBMISSION_DIR/ 2>/dev/null || true
cp docker-compose.yml submission/$SUBMISSION_DIR/

# Remove build artifacts
rm -rf submission/$SUBMISSION_DIR/WebAPI/bin
rm -rf submission/$SUBMISSION_DIR/WebAPI/obj

echo "Creating zip file: $ZIP_NAME"
cd submission/$SUBMISSION_DIR

# Check if zip is available, otherwise use tar
if command -v zip >/dev/null 2>&1; then
    zip -r ../$ZIP_NAME .
else
    echo "Note: zip not found, creating tar.gz instead"
    TAR_NAME="sw4bad-mas1-${AU_ID}.tar.gz"
    tar -czf ../$TAR_NAME .
    echo "Created: $TAR_NAME (rename to .zip if needed)"
fi
cd ../..

rm -rf submission/$SUBMISSION_DIR

echo "✓ Submission package created: submission/$ZIP_NAME"
echo ""
echo "Package contents:"
echo "- WebAPI/ (cleaned .NET solution with Dockerfile)"
echo "- docker-compose.yml (Part C requirement)"
echo "- create_database.sql"
echo "- insert_data.sql"  
echo "- queries.sql"
echo "- ERD.png (Chen notation diagram)"
echo "- design_reasoning.md (design documentation - convert to PDF if required)"
echo ""
echo "⚠️  NOTE: Assignment requires design_reasoning as PDF, not .md"
echo "Ready to submit to Brightspace!"