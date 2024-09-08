# NPSP Quick Importer

**NPSP Quick Importer** is an extension to the **NPSP Data Importer** tool, designed to streamline data imports for nonprofits using Salesforce NPSP. This solution leverages the power of the NPSP Data Importer and enhances the user experience by speeding up the import process. With this tool, you can either import data directly into the **NPSP Data Import object** or choose any other Salesforce object by entering its API name, providing flexibility for use cases beyond the standard NPSP setup. 

## Features

- **Customizable Object Import**: By default, this tool imports into the **NPSP Data Import** object. However, you can toggle the import type and specify any Salesforce object by providing its API name.
  
- **CSV File Upload & Validation**: Users can upload CSV files, and the tool automatically validates the headers against the Salesforce object’s field API names. If the headers don’t match, the import process is halted, and detailed error messages are provided.

- **Enhanced Error Handling**: If any record in a batch fails to insert, the entire batch is rolled back, ensuring data consistency. The tool provides detailed error feedback, helping you resolve issues quickly.

## How This Tool Works with NPSP Data Importer

The **NPSP Quick Importer** works in conjunction with Salesforce's **NPSP Data Importer** by feeding data into the **npsp__DataImport__c** object. Once data is imported into this object, the standard NPSP tools and automation take over to match and process records as part of the overall NPSP workflow.

This tool **does not replace** the NPSP Data Importer but instead **enhances** it by offering an easier, more flexible way to upload, validate, and handle CSV data.

## Key Components

1. **Flow** (`NPSP Quick Importer`): The main flow that guides users through the process of uploading data and setting up batch imports.
   
2. **Lightning Web Component (`csvFileUpload`)**: This component handles the CSV file upload, validating headers, and processing the file before passing the data for batch import.

3. **Apex Classes**:
    - **CsvUploadController**: Retrieves the field API names of the object you want to import data into.
    - **CsvDataProcessor**: Processes the CSV data and handles the actual import into Salesforce objects, supporting both the standard **npsp__DataImport__c** object and any custom object.

## Installation

1. **Install the Unmanaged Package**:
   Install the unmanaged package from this link: [Install NPSP Quick Importer](www.google.com).

2. **Deploy from GitHub**:
   You can also clone this repository and deploy it manually using Salesforce CLI or any deployment tool:
   
   ```bash
   git clone https://github.com/yourusername/npsp-quick-importer.git

## How to Use

1. **Run the Flow**:
   - Navigate to **Setup** → **Flows**.
   - Search for **NPSP Quick Importer** and ensure it is active.
   - Create a quick action or embed the flow inside of a lightning record page. It can also be added to an app's utilities. 

2. **Import Data**:
   - Choose whether to import data into the **NPSP Data Import** object (default) or another Salesforce object by toggling the import type and providing the target object's API name.
   - If importing data into the NPSP Data Import object, select Batch details and click next. 
   - Upload a properly formatted CSV file, and the tool will validate the headers before processing.

3. **CSV File Requirements**:
   - Headers must exactly match the field API names of the object you're importing into.
   - The CSV file should not exceed 10,000 rows to ensure performance and avoid errors.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Feel free to fork this repository, make improvements, and submit pull requests. Contributions are welcome!



