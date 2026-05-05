import React from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './index.module.css';

export default function Home() {
  const { siteConfig } = useDocusaurusContext();

  return (
    <main className={styles.main}>
      <div className={styles.hero}>
        <h1 className={styles.title}>{siteConfig.title}</h1>
        <p className={styles.tagline}>{siteConfig.tagline}</p>
        
        <div className={styles.actions}>
          <Link className="button button--primary button--lg" to="/docs/tutorial/getting-started">
            Get Started
          </Link>
          <Link className="button button--secondary button--lg" to="/docs/howto/howto-create-profile">
            Create a Profile
          </Link>
        </div>
      </div>

      <div className={styles.features}>
        <div className={styles.feature}>
          <h3>📦 Reproducible</h3>
          <p>Your agent sessions become build artifacts with content-addressed paths.</p>
        </div>
        <div className={styles.feature}>
          <h3>🔒 Secure by Default</h3>
          <p>Sandbox isolation is a module option, not a runtime flag.</p>
        </div>
        <div className={styles.feature}>
          <h3>👥 Team Standardization</h3>
          <p>Share profiles via flakes. Everyone gets the exact same environment.</p>
        </div>
      </div>
    </main>
  );
}