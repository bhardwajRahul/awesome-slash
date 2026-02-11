/**
 * @awesome-slash/lib Workspace Tests
 *
 * Validates the lib workspace structure, exports, and require resolution
 * via npm workspaces symlink.
 */

const path = require('path');
const fs = require('fs');

const ROOT_DIR = path.resolve(__dirname, '..');

describe('@awesome-slash/lib workspace', () => {
  let libPkg;

  beforeAll(() => {
    libPkg = require(path.join(ROOT_DIR, 'lib', 'package.json'));
  });

  describe('package.json structure', () => {
    it('should have correct package name', () => {
      expect(libPkg.name).toBe('@awesome-slash/lib');
    });

    it('should use index.js as main entry point', () => {
      expect(libPkg.main).toBe('index.js');
    });

    it('should be a commonjs package', () => {
      expect(libPkg.type).toBe('commonjs');
    });

    it('should have no dependencies', () => {
      expect(libPkg.dependencies).toBeUndefined();
    });
  });

  describe('require resolution', () => {
    it('should resolve root require(@awesome-slash/lib)', () => {
      const lib = require('@awesome-slash/lib');
      expect(lib).toBeDefined();
      expect(typeof lib).toBe('object');
    });

    it('should export expected top-level keys', () => {
      const lib = require('@awesome-slash/lib');
      const expectedKeys = [
        'platform', 'patterns', 'state', 'utils', 'config',
        'sources', 'xplat', 'enhance', 'repoMap', 'perf',
        'collectors', 'discovery'
      ];

      for (const key of expectedKeys) {
        expect(lib[key]).toBeDefined();
      }
    });

    it('should resolve subpath require(@awesome-slash/lib/cross-platform)', () => {
      const crossPlatform = require('@awesome-slash/lib/cross-platform');
      expect(crossPlatform).toBeDefined();
      expect(crossPlatform.PLATFORMS).toBeDefined();
    });

    it('should resolve nested subpath require(@awesome-slash/lib/enhance/agent-patterns)', () => {
      const agentPatterns = require('@awesome-slash/lib/enhance/agent-patterns');
      expect(agentPatterns).toBeDefined();
      expect(agentPatterns.agentPatterns).toBeDefined();
    });

    it('should resolve require(@awesome-slash/lib/sources/custom-handler)', () => {
      const customHandler = require('@awesome-slash/lib/sources/custom-handler');
      expect(customHandler).toBeDefined();
      expect(customHandler.SOURCE_TYPES).toBeDefined();
    });

    it('should resolve require(@awesome-slash/lib/collectors)', () => {
      const collectors = require('@awesome-slash/lib/collectors');
      expect(collectors).toBeDefined();
      expect(typeof collectors.collect).toBe('function');
    });
  });

  describe('index.js entry point', () => {
    it('should exist', () => {
      const indexPath = path.join(ROOT_DIR, 'lib', 'index.js');
      expect(fs.existsSync(indexPath)).toBe(true);
    });
  });
});
