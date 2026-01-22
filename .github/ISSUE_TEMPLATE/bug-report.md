---
name: Bug Report
about: Report a bug in the shared library or data infrastructure
title: "[BUG] Brief description"
labels: bug
assignees: ''
---

## Bug Description

**Summary:**
[Clear and concise description of the bug]

**Component Affected:**
- [ ] Data loader (lib/loaders/)
- [ ] Data processor (lib/processors/)
- [ ] Visualization (lib/viz/)
- [ ] Utilities (lib/utils/)
- [ ] Scripts (scripts/)
- [ ] Data files (data-hub/)
- [ ] Documentation
- [ ] Other: ___

## Steps to Reproduce

1. Step 1
2. Step 2
3. Step 3
4. See error

**Minimal Code Example:**
```python
# Code that reproduces the issue
from lib.loaders import load_mapbiomas

# This fails with...
data = load_mapbiomas(2020)
```

## Expected Behavior

[What you expected to happen]

## Actual Behavior

[What actually happened]

**Error Message:**
```
[Paste the full error message/traceback here]
```

## Environment

**Operating System:**
- [ ] Windows
- [ ] macOS
- [ ] Linux
- [ ] Other: ___

**Python/R Version:**
[e.g., Python 3.9.7, R 4.2.1]

**Key Package Versions:**
```
# Output of pip freeze or sessionInfo()
pandas==2.0.0
geopandas==0.13.0
```

## Data Context

**Data Source:**
[Which data source is affected, if applicable]

**Data Version/Date:**
[e.g., MapBiomas Collection 8, downloaded 2024-01-15]

## Possible Solution

[If you have ideas on how to fix this, describe them here]

## Additional Context

**Screenshots:**
[If applicable, add screenshots]

**Related Issues:**
[Link to related issues, if any]

## Checklist

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have provided a minimal reproducible example
- [ ] I have included the full error message
- [ ] I have listed my environment details
