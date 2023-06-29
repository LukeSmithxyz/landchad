<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:atom="http://www.w3.org/2005/Atom">

  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="/">
    <html>
      <xsl:attribute name="lang">
        <xsl:value-of select="/rss/channel/language" />
      </xsl:attribute>
      <head>
        <title>
          RSS Feed | <xsl:value-of select="/rss/channel/title"/>
        </title>
        <link rel="canonical">
          <xsl:attribute name="href">
            <xsl:value-of select="/rss/channel/link"/>
          </xsl:attribute>
        </link>
        <link rel="stylesheet" type="text/css" href="/style.css"/>
        <link rel="icon" href="/favicon.ico"/>
        <meta name="description">
          <xsl:attribute name="content">
            <xsl:value-of select="/rss/channel/description"/>
          </xsl:attribute>
        </meta>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta name="robots" content="index, follow"/>
        <meta charset="utf-8"/>
      </head>
      <body>
        <main>
          <header>
            <h1>
              <img src="/rss.svg" style="max-height:1.5em" alt="RSS Feed"
                  title="Subscribe via RSS for updates."/>
              RSS Feed Preview
            </h1>
          </header>
          <article>
            <p>
              This is the RSS feed for <xsl:value-of select="rss/channel/title"/>.
              Copy and paste this page's url into your feed reader to subscribe.
            </p>
            <p>
              <input readonly="">
                <xsl:attribute name="value">
                  <xsl:value-of select="/rss/channel/atom:link/@href"/>
                </xsl:attribute>
              </input>
              <button style="display: none;" onclick="copyLink()">Copy</button>
              <script>
                var button = document.querySelector("button");
                var input = document.querySelector("input");
                var myTimeout = null;
                button.style.display = "inline";

                function resetButton() {
                  button.innerText = "Copy";
                }

                function copyLink() {
                  navigator.clipboard.writeText(input.value);
                  button.innerText = "Copied!";
                  if (myTimeout) clearTimeout(myTimeout); // debounce
                  myTimeout = setTimeout(resetButton, 500);
                }
              </script>
            </p>
            <br/>
            <p><xsl:value-of select="/rss/channel/description"/></p>
            <br/>
            <xsl:for-each select="/rss/channel/item">
              <h3>
                <a>
                  <xsl:attribute name="href">
                    <xsl:value-of select="link"/>
                  </xsl:attribute>
                  <xsl:value-of select="title"/>
                </a>
              </h3>
              <p>
                <small>
                  <i>
                    <xsl:value-of select="substring(pubDate, 0, 17)"/>
                  </i>
                </small>
              </p>
              <br/>
            </xsl:for-each>
          </article>
        </main>
        <footer>
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="/rss/channel/link"/>
            </xsl:attribute>
            <xsl:value-of select="/rss/channel/link"/>
          </a>
          <br/>
          <br/>
          <a href="/index.xml">
            <img src="/rss.svg" style="max-height:1.5em" alt="RSS Feed"
                title="Subscribe via RSS for updates."/>
          </a>
        </footer>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
