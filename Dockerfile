FROM really/node-pm2-git:node-9.5.0

MAINTAINER Troy Kelly <troy.kelly@really.ai>

# See https://crbug.com/795759
RUN apk add --no-cache udev ttf-freefont chromium

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Install puppeteer so it's available in the container.
RUN npm i puppeteer

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser && \
    mkdir /home/pptruser/.ssh && \
    touch /home/pptruser/.ssh/repo-key && \
    echo "IdentityFile /home/pptruser/.ssh/repo-key" > /home/pptruser/.ssh/config && \
    chmod 600 /home/pptruser/.ssh/config && \
    chmod 600 /home/pptruser/.ssh/repo-key && \
    mkdir -p /home/pptruser/Downloads

COPY known_hosts /home/pptruser/.ssh/known_hosts
COPY docker-entrypoint.sh /usr/local/bin/

RUN chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules \
    && chown -R pptruser:pptruser /usr/src/app

# Run everything after as non-privileged user.
USER pptruser

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["google-chrome-unstable"]
