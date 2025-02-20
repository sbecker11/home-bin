# Variable Replacement Tool

A Python utility for replacing variables in template files with values from a variables file.

## Installation

1. Clone this repository:
```bash
git clone https://github.com/sbecker11/var-replace.git
cd var-replace
```

2. No additional dependencies required! The script uses only Python standard library.

## Usage

### Basic Command
```bash
python variable-replacer.py template_file variables_file [-o output_file]
```

If no output file is specified, the result will be printed to stdout.

### Example Files

#### Template File (template.json)
```json
{
  "application": {
    "name": "${APP_NAME}",
    "version": "${VERSION}"
  },
  "database": {
    "host": "${DB_HOST}",
    "port": ${DB_PORT}
  }
}
```

#### Variables File (.env)
```
APP_NAME=MyAwesomeApp
VERSION=1.0.0
DB_HOST=db.example.com
DB_PORT=5432
```

### Supported Variable Formats
The tool recognizes variables in these formats:
- `${variable}` (recommended)
- `{{variable}}`
- `%variable%`

### Supported Variables File Formats
- JSON (.json)
- Key-value pairs (.env or any text file)

## Features

- Multiple variable syntax support
- Support for both JSON and .env formats
- Warning for undefined variables
- Optional output file
- Error handling

## File Format Details

### JSON Templates
- Use `${VARIABLE_NAME}` syntax for consistency
- Don't use quotes for numeric values (e.g., `${PORT}`)
- Use quotes for string values (e.g., `"${HOST}"`)

### Environment Variables (.env)
- One variable per line
- Format: `KEY=VALUE`
- No spaces around equal sign
- No quotes needed
- Comments start with #

## Error Handling

The script will:
- Warn about undefined variables
- Handle file read/write errors
- Validate JSON syntax
- Provide clear error messages

## Examples

1. Using JSON template with .env variables:
```bash
python variable-replacer.py template.json .env -o config.json
```

2. Print to stdout:
```bash
python variable-replacer.py template.json variables.env
```

## Project Structure
```
var-replace/
├── README.md
├── variable-replacer.py
├── examples/
│   ├── template.json
│   └── variables.env
```

## Dependencies

- Python 3.6+ (standard library only)

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License
