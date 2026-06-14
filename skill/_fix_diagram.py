#!/usr/bin/env python3
import sys

SKILL_PATH = '/home/tejas/Tejas/Pharos/.worktrees/feat-pharos-power-skill/skill/SKILL.md'

with open(SKILL_PATH, 'r') as f:
    content = f.read()

marker = '## End-to-End Decision Flow'
start_idx = content.find(marker)
end_marker = '## Communication Templates'
end_idx = content.find(end_marker, start_idx)

W = 52
R = 51

lines = []
lines.append('## End-to-End Decision Flow')
lines.append('')
lines.append('```')
lines.append('User request arrives')
lines.append('       │')
lines.append('       ▼')
lines.append('  ┌──────────┐')
# Classify line - ┐ at 51
cl = '  │ Classify  │──→ Is this deployment? ──Yes'
lines.append(cl + '─' * 7 + '┐')
lines.append('  │ (1-2 sec) │' + ' ' * 36 + '│')
lines.append('  └────┬─────┘' + ' ' * 37 + '│')
lines.append('       │ No' + ' ' * 40 + '▼')
lines.append('       ▼' + ' ' * 10 + '┌' + '─' * 32 + '┐')

# Deploy box content lines
# All prefixes must be EXACTLY 14 chars to align with box left│ at 18 and right│ at 51
# Each line: prefix(14) + 4spaces + │(18) + content(32) + │(51) = 52

def box_line(prefix, content):
    """prefix must be 14 chars, content must be 32 chars"""
    assert len(prefix) == 14, f"prefix len={len(prefix)}: '{prefix}'"
    assert len(content) == 32, f"content len={len(content)}: '{content}'"
    return prefix + ' ' * 4 + '│' + content + '│'

lines.append(box_line('  ┌──────────┐', '        Deploy Protocol         '))
lines.append(box_line('  │ Gather   │', '                                '))
# Arrow line: prefix(14) + ───→(4) + │(18→19 pushed) + 31spaces + │(51) = 52
lines.append('  │ context  │' + '───→' + '│' + ' ' * 31 + '│')
lines.append(box_line('  └────┬─────┘', ' 1. Prepare (scripts, env)     '))
# Pipe lines: prefix(14) + 4spaces to 18 + content + │
lines.append(box_line('       │    ', ' 2. Plan (draft command)       '))
lines.append(box_line('       ▼    ', ' 3. Get approval (user confirm) '))
lines.append(box_line('  ┌──────────┐', ' 4. Execute + verify           '))
lines.append(box_line('  │ Plan    │', '    (PharosScan)               '))
lines.append(box_line('  │ (review)│', ' 5. Provide summary            '))
# Box bottom: prefix(14) + 4spaces + └ + 13─ + ┬ + 18─ + ┘ = 52
lines.append(box_line('  │ (review)│', '')[:-1] + '└' + '─' * 13 + '┬' + '─' * 18 + '┘')

# After box: convergence pipe at 32, right border at 51
# Each line: prefix(14) + 18spaces(14-31) + │(32) + 18spaces(33-50) + │(51) = 52
lines.append('  └────┬─────┘' + ' ' * 18 + '│' + ' ' * 18 + '│')
lines.append('       │    ' + ' ' * 21 + '│' + ' ' * 18 + '│')
lines.append('       ▼    ' + ' ' * 21 + '│' + ' ' * 18 + '│')

# Flow section helper - left box + 18char gap + │(32) + 18char gap + │(51)
def flow_line(prefix, gap_left, gap_right):
    """prefix must be 14 chars, gap_left 18 chars, gap_right 18 chars"""
    assert len(prefix) == 14, f"pfx len={len(prefix)}: '{prefix}'"
    assert len(gap_left) == 18, f"gl len={len(gap_left)}: '{gap_left}'"
    assert len(gap_right) == 18, f"gr len={len(gap_right)}: '{gap_right}'"
    return prefix + gap_left + '│' + gap_right + '│'

# Gate
lines.append(flow_line('  ┌──────────┐', '                  ', '                  '))
lines.append(flow_line('  │ Gate     │', '──→ high risk?  ──', 'Yes──→ Get user   '))
lines.append(flow_line('  │ (risk)   │', '     medium risk? ', '─Yes──→ confirm   '))
lines.append(flow_line('  └────┬─────┘', '                  ', '                  '))
lines.append(flow_line('       │    ', '                  ', '                  '))
lines.append(flow_line('       ▼    ', '                  ', '                  '))
# Execute
lines.append(flow_line('  ┌──────────┐', '                  ', '                  '))
lines.append(flow_line('  │ Execute  │', '──→ one change at ', 'a time            '))
lines.append(flow_line('  └────┬─────┘', '                  ', '                  '))
lines.append(flow_line('       │    ', '                  ', '                  '))
lines.append(flow_line('       ▼    ', '                  ', '                  '))
# Verify
lines.append(flow_line('  ┌──────────┐', '                  ', '                  '))
lines.append(flow_line('  │ Verify   │', '──→ Narrowest che ', 'ck                '))
lines.append(flow_line('  └────┬─────┘', '                  ', '                  '))
lines.append(flow_line('       │    ', '                  ', '                  '))
lines.append(flow_line('       ▼    ', '                  ', '                  '))
# Report
lines.append(flow_line('  ┌──────────┐', '                  ', '                  '))
lines.append(flow_line('  │ Report   │', '──→ Standard payl ', 'oad               '))
lines.append(flow_line('  └────┬─────┘', '                  ', '                  '))
lines.append(flow_line('       │    ', '                  ', '                  '))
# Convergence line
lines.append('       └' + '─' * 24 + '┬' + '─' * 18 + '┘')
lines.append('                               │')
lines.append('                               ▼')
lines.append('                             Await next request')
lines.append('```')

new_section = '\n'.join(lines)

# Verify ALL diagram lines are exactly W chars (except tail and ```)
ok = True
in_code = False
for i, line in enumerate(lines):
    if line == '```':
        in_code = not in_code
        continue
    if not in_code:
        continue
    if line.startswith('User') or line.startswith('    '):
        continue  # tail lines
    # Check if this is a tail line (has pipe/arrow at col 31 not 51)
    if '       │' in line and len(line) < 40:
        continue  # convergence tail
    if '       ▼' in line and len(line) < 40:
        continue
    if 'Await' in line:
        continue
    if len(line) != W:
        print(f"LINE {i}: len={len(line)}:")
        print(f"  {repr(line)}")
        ok = False

if not ok:
    print("ERRORS found!")
    sys.exit(1)

print("All lines verified OK")
new_content = content[:start_idx] + new_section + content[end_idx:]
while '\n\n\n' in new_content:
    new_content = new_content.replace('\n\n\n', '\n\n')

with open(SKILL_PATH, 'w') as f:
    f.write(new_content)
print("SUCCESS: Written to file")
