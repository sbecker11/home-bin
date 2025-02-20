

class TreeNode:
    """A flexible tree node that supports both data and visualization."""
  
    def __init__(self, value):
        self.value = value
        self.children = []
    
    def add_child(self, child):
        """Add a child node and return it for chaining."""
        self.children.append(child)
        return child
    
    def __str__(self):
        return str(self.value)

def traverse_tree(node, func, *args, **kwargs):
    """
    Traverse a tree and apply a function to each node.
    
    Args:
        node: The current tree node
        func: Function to apply at each node. Should accept node and any additional args/kwargs
        *args: Additional positional arguments to pass to func
        **kwargs: Additional keyword arguments to pass to func
    
    Returns:
        List of results from function application at each node
    """
    # Apply function to current node
    result = [func(node, *args, **kwargs)]
    
    # Recursively process children
    for child in node.children:
        result.extend(traverse_tree(child, func, *args, **kwargs))
    
    return result

def print_tree(node, level=0, indent="    ", prefix=""):
    """
    Print a tree with branch-style indentation.
    
    Args:
        node: The current tree node
        level: Current depth in the tree
        indent: Indentation string (default: 4 spaces)
        prefix: Optional prefix for each line (e.g., "├── " for branch)
    """
    # Print current node with indentation
    if level == 0:
        print(f"{node}")  # Root node without prefix
    else:
        print(f"{indent * (level-1)}{prefix}{node}")
    
    # Print children
    for i, child in enumerate(node.children):
        is_last = i == len(node.children) - 1
        # Use different prefix for last child
        child_prefix = "└── " if is_last else "├── "
        print_tree(child, level + 1, indent, child_prefix)

def print_tree_simple(node, level=0):
    """Simple tree printing with basic indentation."""
    print("  " * level + str(node))
    for child in node.children:
        print_tree_simple(child, level + 1)

# Example processing functions
def process_node(node, multiplier=1, offset=0):
    """Example processing function that modifies numeric values."""
    if isinstance(node.value, (int, float)):
        result = node.value * multiplier + offset
        print(f"Processing {node.value} -> {result}")
        return result
    return node.value

def collect_values(node):
    """Example function to collect all values in the tree."""
    return node.value

# Example usage and demonstration
def create_sample_tree():
    """Create a sample tree for demonstration."""
    root = TreeNode("Project")
    
    # Level 1
    docs = root.add_child(TreeNode("docs"))
    src = root.add_child(TreeNode("src"))
    tests = root.add_child(TreeNode("tests"))
    
    # Level 2 under docs
    docs.add_child(TreeNode("api.rst"))
    docs.add_child(TreeNode("user_guide.rst"))
    
    # Level 2 under src
    module1 = src.add_child(TreeNode("module1"))
    module2 = src.add_child(TreeNode("module2"))
    
    # Level 3 under modules
    module1.add_child(TreeNode("core.py"))
    module1.add_child(TreeNode("utils.py"))
    module2.add_child(TreeNode("handlers.py"))
    
    # Level 2 under tests
    tests.add_child(TreeNode("test_core.py"))
    tests.add_child(TreeNode("test_utils.py"))
    
    return root

if __name__ == "__main__":
    # Create and display sample tree
    tree = create_sample_tree()
    
    print("\nTree with simple indentation:")
    print_tree_simple(tree)
    
    print("\nTree with branch markers:")
    print_tree(tree)
    
    # Example of using traverse_tree with different functions
    print("\nCollecting all values:")
    values = traverse_tree(tree, collect_values)
    print(f"All values: {values}")
    
    # Create a numeric tree for processing example
    numeric_tree = TreeNode(1)
    numeric_tree.add_child(TreeNode(2)).add_child(TreeNode(4))
    numeric_tree.add_child(TreeNode(3)).add_child(TreeNode(6))
    
    print("\nProcessing numeric tree:")
    print("Original tree:")
    print_tree(numeric_tree)
    
    print("\nProcessed values (multiplier=2, offset=1):")
    results = traverse_tree(numeric_tree, process_node, multiplier=2, offset=1)
    print(f"Results: {results}")
