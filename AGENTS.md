# AI-DLC Development Workflow

## MANDATORY: All development work on this project MUST follow the AI-DLC (AI-Driven Development Life Cycle) process.

When receiving ANY software development request (new features, bug fixes, enhancements, refactoring), you MUST:

1. **Load the AI-DLC workflow rules** from `.github/copilot-instructions.md` -- this is the primary governance document
2. **Load the detailed rule files** from `.aidlc-rule-details/` directory (common/, inception/, construction/, extensions/)
3. **Check project state** by reading `aidlc-docs/aidlc-state.md` for current lifecycle position
4. **Follow the workflow** from the appropriate stage (resume if in progress, or start from Workspace Detection for new requests)

## Quick Reference: AI-DLC Phases

```
INCEPTION:  Workspace Detection -> Reverse Engineering (if brownfield) -> Requirements Analysis -> User Stories (conditional) -> Workflow Planning -> Application Design (conditional) -> Units Generation (conditional)
CONSTRUCTION:  Per-unit: Functional Design -> NFR Requirements -> NFR Design -> Infrastructure Design -> Code Generation -> Build and Test
OPERATIONS:  Placeholder
```

## Key Rules

- **Never skip Workspace Detection, Requirements Analysis, Workflow Planning, Code Generation, or Build and Test** -- these always execute
- **Always log interactions in `aidlc-docs/audit.md`** with timestamps
- **Always use question file format** (A/B/C/X choices with [Answer]: tags) per `.aidlc-rule-details/common/question-format-guide.md`
- **Always get explicit user approval** before proceeding between stages
- **Check Extension Configuration** in `aidlc-state.md` before enforcing extension rules
- **Application code goes in workspace root, documentation goes in `aidlc-docs/` only**
