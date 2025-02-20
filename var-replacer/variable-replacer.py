import json
import argparse
import re
from pathlib import Path

class VariableReplacer:
    """Class to replace variables in a template file with values from a variables file."""
    def __init__(self):
        self.variables = {}
    
    def load_variables(self, variables_file):
        """Load variables from JSON or simple key=value file"""
        file_path = Path(variables_file)
        content = file_path.read_text()
        
        if file_path.suffix.lower() == '.json':
            self.variables = json.loads(content)
        else:
            # Assume simple key=value format (.env style)
            for line in content.splitlines():
                line = line.strip()
                if line and '=' in line and not line.startswith('#'):
                    key, value = line.split('=', 1)
                    self.variables[key.strip()] = value.strip()
    
    def process_template(self, template_file, output_file=None):
        """Replace variables in template file with their values"""
        template_path = Path(template_file)
        content = template_path.read_text()
        
        # Support multiple variable formats: ${var}, {{var}}, and %var%
        patterns = [
            (r'\$\{([^}]+)\}', '${0}'),  # ${variable}
            (r'\{\{([^}]+)\}\}', '{{0}}'),  # {{variable}}
            (r'%([^%]+)%', '%0%')  # %variable%
        ]
        
        # Perform replacements
        modified_content = content
        for pattern, _ in patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                var_name = match.group(1).strip()
                if var_name in self.variables:
                    placeholder = match.group(0)
                    modified_content = modified_content.replace(
                        placeholder, 
                        str(self.variables[var_name])
                    )
                else:
                    print(f"Warning: Variable '{var_name}' not found in variables file")
        
        # Write to output file or print to console
        if output_file:
            output_path = Path(output_file)
            output_path.write_text(modified_content)
            print(f"Output written to: {output_file}")
        else:
            print(modified_content)

def main():
    """Main function to parse arguments and replace variables in the template file."""
    parser = argparse.ArgumentParser(
        description='Replace variables in a template file with values from a variables file'
    )
    parser.add_argument('template', help='Template file with variables to replace')
    parser.add_argument('variables', help='File containing variable values (JSON or key=value format)')
    parser.add_argument('-o', '--output', help='Output file (optional, defaults to stdout)')
    
    args = parser.parse_args()
    
    replacer = VariableReplacer()
    try:
        replacer.load_variables(args.variables)
        replacer.process_template(args.template, args.output)
    except (FileNotFoundError, json.JSONDecodeError, IOError) as e:
        print(f"Error: {e}")
        return 1
    
    return 0

if __name__ == '__main__':
    exit(main())