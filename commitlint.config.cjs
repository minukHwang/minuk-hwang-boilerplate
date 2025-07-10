module.exports = {
  extends: ['@commitlint/config-conventional', 'gitmoji'],
  rules: {
    // 허용되는 커밋 타입 정의 (기존 유지)
    'type-enum': [
      2, // error level
      'always',
      [
        'feat',     // 새로운 기능
        'fix',      // 버그 수정
        'docs',     // 문서 수정
        'style',    // 코드 스타일 변경 (기능에 영향 없음)
        'refactor', // 코드 리팩토링
        'perf',     // 성능 개선
        'test',     // 테스트 추가/수정
        'build',    // 빌드 시스템 변경
        'ci',       // CI/CD 설정 변경
        'chore',    // 기타 작업
        'revert',   // 이전 커밋 되돌리기
        'init',     // 초기 설정
      ],
    ],
    'subject-case': [0], // subject 대소문자 규칙 비활성화 (이모지 사용 가능)
    'subject-empty': [2, 'never'], // subject가 비어있으면 에러
    'type-empty': [2, 'never'],    // type이 비어있으면 에러
    'start-with-gitmoji': [2, 'always'], // gitmoji로 시작하는 커밋 메시지 강제
  },
  prompt: {
    questions: {
      type: {
        description: 'What type of change are you making to the codebase?',
        enum: {
          feat: {
            description: 'Adding a new feature or capability to the application',
            title: 'Features',
            emoji: '✨',
          },
          fix: {
            description: 'Resolving a bug or issue that was causing problems',
            title: 'Bug Fixes',
            emoji: '🐛',
          },
          docs: {
            description: 'Updating documentation, comments, or README files',
            title: 'Documentation',
            emoji: '📚',
          },
          style: {
            description: 'Formatting code, fixing whitespace, or adjusting styling without changing functionality',
            title: 'Styles',
            emoji: '💎',
          },
          refactor: {
            description: 'Restructuring existing code to improve readability or maintainability',
            title: 'Code Refactoring',
            emoji: '📦',
          },
          perf: {
            description: 'Optimizing code execution speed, memory usage, or resource consumption',
            title: 'Performance Improvements',
            emoji: '🚀',
          },
          test: {
            description: 'Adding new test cases, fixing existing tests, or improving test coverage',
            title: 'Tests',
            emoji: '🚨',
          },
          build: {
            description: 'Modifying build tools, dependencies, or deployment configuration',
            title: 'Builds',
            emoji: '🛠',
          },
          ci: {
            description: 'Updating continuous integration workflows, GitHub Actions, or deployment scripts',
            title: 'Continuous Integrations',
            emoji: '🔗',
          },
          chore: {
            description: 'Routine maintenance tasks, dependency updates, or configuration changes',
            title: 'Chores',
            emoji: '📝',
          },
          revert: {
            description: 'Undoing a previous commit that introduced issues or unwanted changes',
            title: 'Reverts',
            emoji: '🗑',
          },
          init: {
            description: 'Setting up the project structure, initial configuration, or boilerplate code',
            title: 'Initialization',
            emoji: '🎉',
          },
        },
      },
      scope: {
        description: 'Which part of the codebase is affected by this change? (e.g., component name, file path, or module)',
      },
      subject: {
        description: 'Provide a concise summary of what this change accomplishes',
      },
      body: {
        description: 'Explain the reasoning behind this change and any important details (optional)',
      },
    },
  },
};
