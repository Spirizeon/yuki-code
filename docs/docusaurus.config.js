/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Yuki',
  tagline: 'Reproducible Agent Sessions for AI Engineering Teams',
  url: 'https://yuki-code.pages.dev',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  organizationName: 'Spirizeon',
  projectName: 'yuki-code',

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          routeBasePath: '/',
          showLastUpdateTime: true,
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'Yuki',
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Docs',
          },
          {
            type: 'doc',
            docId: 'changelog',
            position: 'left',
            label: 'Changelog',
          },
          {
            href: 'https://github.com/Spirizeon/yuki-code',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        style: 'dark',
        copyright: `Copyright ${new Date().getFullYear()} Spirizeon. Built with Docusaurus.`,
      },
    }),
};

module.exports = config;