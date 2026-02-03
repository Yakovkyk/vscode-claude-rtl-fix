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

**Important:** Claude Code's CSS module/variable names (like `Ln`, `k2`, `An`, `u2`) change between versions.
Always search by **property names** (like `messagesContainer`, `questionsContainer`) which stay consistent.
The class name values may be either minified (`"U"`, `"e"`) or CSS Module hashed (`"message_07S1Yg"`).

1. Read the backup file (original version without injection):
   `webview/index.js.backup` (if exists) or `webview/index.js` (if RTL not installed)

2. Search for the **chat messages CSS module** by property name:
   ```
   grep -oP '\w+\s*=\s*\{[^}]*messagesContainer[^}]{0,500}' <path-to-backup>
   ```
   This will return something like (minified):
   ```
   Ln={chatContainer:"ri",messagesContainer:"P",message:"U",userMessageContainer:"N",userMessage:"ai",timelineMessage:"e",...}
   ```
   Or (CSS Modules, newer versions):
   ```
   k2={chatContainer:"chatContainer_07S1Yg",messagesContainer:"messagesContainer_07S1Yg",message:"message_07S1Yg",userMessageContainer:"userMessageContainer_07S1Yg",userMessage:"userMessage_07S1Yg",timelineMessage:"timelineMessage_07S1Yg",...}
   ```

3. Extract the relevant class names:
   - `message` - single message class
   - `userMessageContainer` - user message container class
   - `timelineMessage` - assistant message class
   - `userMessage` - user message text class

4. Also search for dialog CSS modules:

   **AskUserQuestion module** (question dialogs with options):
   ```
   grep -oP '\w+\s*=\s*\{[^}]*questionsContainer[^}]{0,500}' <path-to-backup>
   ```
   Extract:
   - `questionsContainer`
   - `questionTextLarge`
   - `option`
   - `optionLabel`
   - `optionDescription`
   - `navigationBar`
   - `navTab`
   - `otherInput`

   **Permission module** (action approval dialogs):
   ```
   grep -oP '\w+\s*=\s*\{[^}]*permissionRequestContainer[^}]{0,500}' <path-to-backup>
   ```
   Extract:
   - `permissionRequestContainer`
   - `permissionRequestHeader`
   - `permissionRequestDescription`

5. Compare with selectors in `rtl-claude-code.js`:
   - Check the `chatSelectors` block - verify it matches the chat module class names
   - Check the `dialogSelectors` block - verify it matches the question and permission module class names
   - **Both must be checked!**

6. **If selectors don't match** - update `rtl-claude-code.js`:
   - Update `chatSelectors` with new class names
   - Update `dialogSelectors` with new class names
   - chatSelectors format: `.{message}.{userMessageContainer}` for user messages, `.{message}.{timelineMessage}` for assistant messages, `.{userMessage}` for text
   - Update comments to note the version and module variable name

#### Example - chatSelectors (minified):
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

#### Example - chatSelectors (CSS Modules / hashed):
If you found `k2={...,message:"message_07S1Yg",userMessageContainer:"userMessageContainer_07S1Yg",timelineMessage:"timelineMessage_07S1Yg",userMessage:"userMessage_07S1Yg",...}`:
```javascript
chatSelectors: [
    ...
    '.message_07S1Yg.userMessageContainer_07S1Yg',   // k2.message + k2.userMessageContainer
    '.message_07S1Yg.timelineMessage_07S1Yg',        // k2.message + k2.timelineMessage
    '.userMessage_07S1Yg',                            // k2.userMessage
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
