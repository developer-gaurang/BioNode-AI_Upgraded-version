import os

file_path = r"lib/main.dart"
with open(file_path, "r", encoding="utf-8") as f:
    text = f.read()

# Replace colors to match the Sci-Fi Neon Cyberpunk UI
replacements = {
    "0xFFA855F7": "0xFF00E5FF", # Purple to Neon Cyan
    "0xFFC084FC": "0xFFD500F9", # Light Purple to Electric Purple 
    "0xFF0A0A0A": "0xFF050B14", # Black to Deep Space Blue/Black
    "0xFF050505": "0xFF02040A", # Blacker to Deep Space Darker
    "0xFF111111": "0xFF0A101D", # Card background to Deep Blue Tint
    "OutFit": "Orbitron", # Font check (optional, but let's stick to colors first)
}

for old, new in replacements.items():
    text = text.replace(old, new)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(text)

print("Theme successfully updated globally.")
