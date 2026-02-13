const { parseCommand } = require('../lib/utils/command-parser');

describe('command parser', () => {
  test('parses simple command into executable and args', () => {
    const parsed = parseCommand('npm test -- --watch');
    expect(parsed.executable).toBe('npm');
    expect(parsed.args).toEqual(['test', '--', '--watch']);
  });

  test('parses quoted arguments with spaces', () => {
    const parsed = parseCommand('node -e "console.log(\\"hello world\\")"');
    expect(parsed.executable).toBe('node');
    expect(parsed.args).toEqual(['-e', 'console.log("hello world")']);
  });

  test('preserves escaped sequences inside double quotes', () => {
    const parsed = parseCommand('node -e "console.log(\"line1\\nline2\")"');
    expect(parsed.args[1]).toContain('\\n');
  });

  test('throws on unterminated quote', () => {
    expect(() => parseCommand('node -e "console.log(1)')).toThrow('unterminated quote');
  });

  test('throws on empty command', () => {
    expect(() => parseCommand('   ')).toThrow('must be a non-empty string');
  });
});
