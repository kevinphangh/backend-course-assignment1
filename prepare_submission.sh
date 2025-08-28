#!/bin/bash
# Prepares SW4BAD Assignment 1 for submission

echo "Preparing SW4BAD Assignment 1 for submission..."

# Require AU ID parameter
if [ -z "$1" ]; then
    echo "Usage: ./prepare_submission.sh <your-au-id>"
    echo "Example: ./prepare_submission.sh au123456"
    exit 1
fi

AU_ID=$1
SUBMISSION_DIR="submission_temp"
ZIP_NAME="sw4bad-mas1-${AU_ID}.zip"

echo "Cleaning solution..."
cd src/WebAPI && dotnet clean && cd ../..

echo "Creating submission structure..."
rm -rf $SUBMISSION_DIR
mkdir -p $SUBMISSION_DIR

# Copy files to flat structure for submission
cp -r src/WebAPI $SUBMISSION_DIR/
cp database/scripts/create_database.sql $SUBMISSION_DIR/
cp database/scripts/insert_data.sql $SUBMISSION_DIR/
cp database/scripts/queries.sql $SUBMISSION_DIR/
cp database/ERD.png $SUBMISSION_DIR/
cp database/design_reasoning.md $SUBMISSION_DIR/

# Remove build artifacts
rm -rf $SUBMISSION_DIR/WebAPI/bin
rm -rf $SUBMISSION_DIR/WebAPI/obj

echo "Creating zip file: $ZIP_NAME"
cd $SUBMISSION_DIR
zip -r ../$ZIP_NAME .
cd ..

rm -rf $SUBMISSION_DIR

echo "✓ Submission package created: $ZIP_NAME"
echo ""
echo "Package contents:"
echo "- WebAPI/ (cleaned .NET solution)"
echo "- create_database.sql"
echo "- insert_data.sql"  
echo "- queries.sql"
echo "- ERD.png (Chen notation diagram)"
echo "- design_reasoning.md (comprehensive design documentation)"
echo ""
echo "Note: If PDF format is required for design_reasoning, convert the .md file to PDF"
echo "Ready to submit to Brightspace!"