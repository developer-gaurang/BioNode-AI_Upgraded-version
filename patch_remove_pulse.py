import re

file_path = r"d:\Projects\My_Apps\bionode_ai\lib\main.dart"

with open(file_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

print(f"Total lines: {len(lines)}")

# ─── 1. Remove CommunityTab from _pages list (line 783, 0-indexed 782) ───
# Line 783: "    const CommunityTab(),\r\n"
lines[782] = ""  # Remove that line

# ─── 2. Remove PULSE nav item (line 838, 0-indexed 837) ───
# Line 838: "                _buildNavItem(Icons.wifi_tethering_rounded, 'PULSE', 3),\r\n"
lines[837] = ""  # Remove that line

# ─── 3. Remove entire CommunityTab section (lines 2824-3056, 0-indexed 2823-3055) ───
# Line 2824: "// --- TAB 4: COMMUNITY PULSE ---"  (approx, find exact)
# Line 3057 == class PricingScreen  (0-indexed 3056)

# Find the start of TAB 4 section comment (a bit before line 2831)
start_community = None
end_community = None
for i, line in enumerate(lines):
    if "TAB 4: COMMUNITY PULSE" in line and start_community is None:
        # Go back to find the ==== line
        for j in range(i, max(0, i-5), -1):
            if "==============" in lines[j]:
                start_community = j
                break
        if start_community is None:
            start_community = i
    if "class PricingScreen" in line:
        end_community = i
        break

print(f"CommunityTab section: lines {start_community+1} to {end_community} (removing)")
print(f"First line: {lines[start_community].strip()}")
print(f"Last line before PricingScreen: {lines[end_community-1].strip()}")

# Zero out those lines
for i in range(start_community, end_community):
    lines[i] = ""

with open(file_path, "w", encoding="utf-8", newline='\r\n') as f:
    f.writelines(lines)

print("Done!")
