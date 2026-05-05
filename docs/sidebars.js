/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  tutorial: [
    {
      type: 'category',
      label: 'Tutorials',
      collapsed: false,
      items: [
        'tutorial/getting-started',
        'tutorial/first-session',
      ],
    },
  ],

  howto: [
    {
      type: 'category',
      label: 'How-to Guides',
      items: [
        'howto/howto-create-profile',
        'howto/howto-team-setup',
        'howto/howto-cicd',
        'howto/howto-mcp-servers',
      ],
    },
  ],

  reference: [
    {
      type: 'category',
      label: 'Reference',
      items: [
        'reference/reference-cli',
        'reference/reference-options',
      ],
    },
  ],

  explanation: [
    {
      type: 'category',
      label: 'Explanation',
      items: [
        'explanation/explanation-philosophy',
      ],
    },
  ],
};

module.exports = sidebars;