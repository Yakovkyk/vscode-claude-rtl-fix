---
name: rtl-fix
description: Diagnose and fix RTL (right-to-left) support for Claude Code in VS Code. Use when the user complains about Hebrew/Arabic text appearing left-to-right instead of right-to-left, or when the user asks about the RTL extension.
disable-model-invocation: false
allowed-tools: Bash, Read, Glob, Grep, Edit, AskUserQuestion
---

# RTL Fix - Claude Code Skill

## Background

RTL support works by injecting JavaScript code into `webview/index.js` of the Claude Code VS Code extension.
When Claude Code updates to a new version, the file is replaced and the injection is lost.
Additionally, CSS class names are minified and change between versions - so they need to be scanned and updated.

- Install script: [scripts/install.ps1](scripts/install.ps1) (inside the skill folder)
- RTL injection code: [scripts/rtl-claude-code.js](scripts/rtl-claude-code.js) (inside the skill folder)
- VS Code extensions folder: `~/.vscode/extensions/anthropic.claude-code-*`

## How to Handle Conversations

Language: follow the user's language.

### Step 1: Assess the Situation

When the skill is activated, **always start with a silent check**:
1. Check which Claude Code versions exist
2. Check which ones have RTL installed (search for "RTL Support for Claude Code" in webview/index.js)
3. **Check selector compatibility** (Step 1.5 - see below)

After checking, show the user a brief status summary and ask what they need via AskUserQuestion:

- **Reinstall** - inject RTL into a version that doesn't have it
- **Status check only** - already displayed, maybe that's enough
- **Something else** - bug fix, upgrade, explanation, etc.

### Step 1.5: Scan Selector Compatibility (mandatory!)

**This is the critical step.** CSS class names in Claude Code are minified and change every version.
This check must be done every time, even if RTL is already installed.

#### How to scan current class names:

1. Read the backup file (original version without injection):
   `webview/index.js.backup` (if exists) or `webview/index.js` (if RTL not installed)

2. Search for the Ln CSS module definition (chat messages module):
   ```
   grep -oP 'Ln\s*=\s*\{[^}]{0,500}' <path-to-backup>
   ```
   This will return something like:
   ```
   Ln={chatContainer:"ri",messagesContainer:"P",message:"U",userMessageContainer:"N",userMessage:"ai",timelineMessage:"e",...}
   ```

3. Extract the relevant class names:
   - `message` - single message class (e.g. `"U"`)
   - `userMessageContainer` - user message container class (e.g. `"N"`)
   - `timelineMessage` - assistant message class (e.g. `"e"`)
   - `userMessage` - user message text class (e.g. `"ai"`)

4. Also search for dialog CSS modules:

   **AskUserQuestion module** (question dialogs with options):
   ```
   grep -oP '\w+\s*=\s*\{[^}]*questionsContainer[^}]{0,500}' <path-to-backup>
   ```
   This will return something like:
   ```
   An={questionsContainer:"an",questionBlock:"pn",questionTextLarge:"sn",option:"eo",optionLabel:"kn",optionDescription:"yn",navigationBar:"en",navTab:"Ko",otherInput:"ro",...}
   ```
   Extract:
   - `questionsContainer` (e.g. `"an"`)
   - `questionTextLarge` (e.g. `"sn"`)
   - `option` (e.g. `"eo"`)
   - `optionLabel` (e.g. `"kn"`)
   - `optionDescription` (e.g. `"yn"`)
   - `navigationBar` (e.g. `"en"`)
   - `navTab` (e.g. `"Ko"`)
   - `otherInput` (e.g. `"ro"`)

   **Permission module** (action approval dialogs):
   ```
   grep -oP '\w+\s*=\s*\{[^}]*permissionRequestContainer[^}]{0,500}' <path-to-backup>
   ```
   Extract:
   - `permissionRequestContainer` (e.g. `"t"`)
   - `permissionRequestHeader` (e.g. `"Co"`)
   - `permissionRequestDescription` (e.g. `"a"`)

5. Compare with selectors in `rtl-claude-code.js`:
   - Check the `chatSelectors` block - verify it matches Ln class names
   - Check the `dialogSelectors` block - verify it matches An and ai class names
   - **Both must be checked!**

6. **If selectors don't match** - update `rtl-claude-code.js`:
   - Update `chatSelectors` with new class names
   - Update `dialogSelectors` with new class names
   - chatSelectors format: `.{message}.{userMessageContainer}` for user messages, `.{message}.{timelineMessage}` for assistant messages, `.{userMessage}` for text
   - Update comments to note the version

#### Example - chatSelectors:
If you found `Ln={...,message:"Q",userMessageContainer:"Z",timelineMessage:"f",userMessage:"bx",...}`:
```javascript
chatSelectors: [
    ...
    '.Q.Z',   // Ln.message + Ln.userMessageContainer
    '.Q.f',   // Ln.message + Ln.timelineMessage
    '.bx',    // Ln.userMessage
    ...
]
```

#### Example - dialogSelectors:
If you found `An={questionsContainer:"xy",questionTextLarge:"ab",...}` and `ai={permissionRequestContainer:"cd",...}`:
```javascript
dialogSelectors: {
    questionsContainer: '.xy',    // An.questionsContainer
    questionText: '.ab',          // An.questionTextLarge
    ...
    permissionContainer: '.cd',   // ai.permissionRequestContainer
    ...
}
```

### Step 2: Confirm Before Action

Before any file-changing action:
- Briefly explain what you're about to do
- If selectors changed - show the user a table of changes
- Ask for user confirmation

### Step 3: Execute (only after confirmation)

#### 3a: Update the Code (if selectors changed)

1. Edit `rtl-claude-code.js` in the skill scripts folder
2. Update the selectors to match the new class names

#### 3b: Install RTL in Extension

1. If RTL is already installed with old selectors - restore from backup:
   ```
   cp <path>/webview/index.js.backup <path>/webview/index.js
   ```
2. Run the install script:
   ```
   powershell -ExecutionPolicy Bypass -File "<skill-folder>/scripts/install.ps1"
   ```
3. Verify injection succeeded (search for the string and verify new selectors are there)

### Step 4: Summary

Report:
- What was done
- Current status
- Whether selectors were updated (and if so, what changed)
- If installed: remind to **restart VS Code** (Ctrl+Shift+P -> Reload Window)
