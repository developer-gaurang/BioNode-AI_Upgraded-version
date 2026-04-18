import re

def main():
    with open('lib/main.dart', 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    output = []
    
    for i, line in enumerate(lines):
        if 'ScaffoldMessenger.of(context).showSnackBar' in line:
            block = []
            block.append(f'---\nLine {i+1}: {line.strip()}')
            for j in range(i+1, min(i+10, len(lines))):
                block.append(f'  L{j+1}: {lines[j].strip()}')
                if ')' in lines[j] and ';' in lines[j]:  # Rough heuristic for end of call
                    pass # We will just grab 10 lines
            output.extend(block)
            
    with open('output_snack.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(output))

if __name__ == "__main__":
    main()
