/** @type {import('@commitlint/types').UserConfig} */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // new feature
        'fix',      // bug fix
        'docs',     // documentation only
        'style',    // formatting, no logic change
        'refactor', // code change that is neither fix nor feature
        'test',     // adding / correcting tests
        'chore',    // build process, tooling, config
        'ci',       // CI/CD configuration
        'perf',     // performance improvement
        'revert',   // revert a previous commit
        'track',    // adding or updating training module content (custom)
      ],
    ],
    'scope-case': [2, 'always', 'kebab-case'],
    'subject-case': [2, 'always', 'lower-case'],
    'header-max-length': [2, 'always', 100],
    'body-max-line-length': [2, 'always', 120],
  },
};
