# ⚠️ WARNINGS - READ BEFORE USING ⚠️

## This Addon Is Not Tested

- **Never** run in a real raid environment
- **Never** rely on its output for actual decision-making
- **Never** blame this addon when your guild wipes
- **Never** show this to your raid leader expecting it to work

## Potential Catastrophes

1. **UI Might Not Show Up** - The frame creation uses deprecated APIs
2. **Events Won't Fire** - Event registration might not work correctly
3. **API Calls Could Fail** - `GetEncounterInfo()`, `GetGuildInfo()` usage untested
4. **Memory Leaks** - No cleanup, frames persist forever
5. **Slash Commands Might Break** - WoW slash command registration can be finicky
6. **Incompatible With Current Patch** - Written for general WoW, not tested on live servers

## What Will Happen

- Addon loads silently without error messages
- UI frame might not appear at all
- Raid roster detection will probably fail
- Difficulty suggestions will be wrong
- Your guild will question your sanity

## If You Still Want to Test

1. Make a backup of your WoW configuration
2. Test in a non-raid scenario first
3. Have `/reload` ready to disable it instantly
4. Keep `/raidplan reset` in your macros
5. Expect the worst

## The Code Quality

- No validation
- No error handling
- No comments explaining the logic
- Magic numbers everywhere
- Hardcoded boss IDs that might be wrong
- Guild detection threshold is arbitrary
- Zero defensive programming

## Legal Disclaimer

This addon is provided "as-is" with absolutely no warranty. By using it, you accept that:
- It will likely break
- It will definitely be wrong
- It will possibly ruin your raid
- The author accepts zero responsibility

**Use at your own risk. Your wipes are not our fault.**
