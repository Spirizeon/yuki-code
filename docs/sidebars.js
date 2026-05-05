/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  sidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      collapsed: false,
      items: [
        'intro',
        'quick-start',
      ],
    },
    {
      type: 'category',
      label: 'Core Concepts',
      items: [
        'soul',
        'skill',
        'usage',
      ],
    },
    {
      type: 'category',
      label: 'Meta',
      items: [
        'changelog',
      ],
    },
  ],
};

module.exports = sidebars;