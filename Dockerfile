FROM ghost:4.48-alpine as cloudinary
WORKDIR $GHOST_INSTALL/current
RUN su-exec node yarn add ghost-storage-cloudinary@2

ENV url "http://localhost:2368"
# cloudinary://my_key:my_secret@my_cloud_name
ENV CLOUDINARY_URL "cloudinary://my_key:my_secret@my_cloud_name" 

FROM ghost:4.48-alpine
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/current/node_modules $GHOST_INSTALL/current/node_modules
COPY --chown=node:node --from=cloudinary $GHOST_INSTALL/current/node_modules/ghost-storage-cloudinary $GHOST_INSTALL/current/core/server/adapters/storage/ghost-storage-cloudinary

RUN set -ex; \
    su-exec node ghost config storage.active ghost-storage-cloudinary; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.use_filename true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.unique_filename false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.upload.overwrite false; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.quality auto; \    
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.cdn_subdomain true; \
    su-exec node ghost config storage.ghost-storage-cloudinary.fetch.secure true; \
    su-exec node ghost config imageOptimization.resize false;
