# RTL Fix for Claude Code in VS Code

תמיכת RTL (עברית, ערבית, פרסית) עבור תוסף Claude Code ב-Visual Studio Code.

## מה זה עושה

Claude Code ב-VS Code מציג טקסט בעברית בכיוון הפוך (שמאל-לימין במקום ימין-לשמאל). התוסף הזה מתקן את זה על ידי הזרקת קוד JavaScript ל-webview של Claude Code.

**מה מכוסה:**
- הודעות צ'אט (של המשתמש ושל Claude)
- דיאלוגים של שאלות ואפשרויות (AskUserQuestion)
- דיאלוגי אישור (Permission requests)
- שדה הקלט (input box)
- בלוקי קוד נשארים LTR (כמו שצריך)

## למה צריך סקיל (ולא רק להתקין פעם אחת)

Claude Code **מתעדכן תכופות**. בכל עדכון, הקובץ שאליו מזריקים את הקוד (`webview/index.js`) מוחלף בגרסה נקייה - וה-RTL נעלם.

בנוסף, ה-CSS class names של Claude Code הם **minified ומשתנים בין גרסאות**. כלומר, גם הקוד עצמו צריך עדכון כדי להתאים ל-class names החדשים.

הסקיל (`SKILL.md`) מלמד את Claude Code (CLI) לסרוק את הגרסה הנוכחית, לזהות את ה-class names הנכונים, לעדכן את הקוד, ולהזריק אותו מחדש - אוטומטית.

**הזרימה:**
1. Claude Code מתעדכן --> ה-RTL נעלם
2. אתה אומר ל-Claude: "תתקן לי את ה-RTL" (או מפעיל את הסקיל)
3. Claude סורק, מעדכן סלקטורים, מזריק מחדש
4. עובד שוב

## התקנה

### שלב 1: העתקת הקבצים

העתק את שלושת הקבצים לתיקייה במחשב שלך (למשל `~/claude-rtl/`):
- `rtl-claude-code.js` - קוד ה-RTL
- `install.ps1` - סקריפט התקנה

### שלב 2: הרצת סקריפט ההתקנה

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

הסקריפט:
- מוצא אוטומטית את תיקיית Claude Code
- יוצר גיבוי של הקובץ המקורי
- מזריק את קוד ה-RTL

### שלב 3: הפעלה מחדש

`Ctrl+Shift+P` --> "Reload Window"

### שלב 4 (מומלץ): התקנת הסקיל

העתק את `SKILL.md` לתיקיית הסקילים של Claude Code:
```
~/.claude/skills/rtl-fix/SKILL.md
```

והעתק גם את הסקריפטים:
```
~/.claude/skills/rtl-fix/scripts/rtl-claude-code.js
~/.claude/skills/rtl-fix/scripts/install.ps1
```

מעכשיו, כשה-RTL יישבר (בגלל עדכון), פשוט תגיד ל-Claude: "תתקן לי את ה-RTL" והוא יעשה את הכל לבד.

## הסרה

שחזור מגיבוי:
```powershell
# מצא את התיקייה
ls $env:USERPROFILE\.vscode\extensions\anthropic.claude-code-*

# שחזר
cp <path>\webview\index.js.backup <path>\webview\index.js
```

## מבנה הקבצים

```
claude-code-rtl-fix/
├── README.md              <-- אתה כאן
├── rtl-claude-code.js     <-- קוד ה-RTL (מוזרק ל-webview)
├── install.ps1            <-- סקריפט התקנה (PowerShell)
└── SKILL.md               <-- סקיל ל-Claude Code (לתחזוקה אוטומטית)
```
