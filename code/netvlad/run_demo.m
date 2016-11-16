setup;
netID= 'vd16_tokyoTM_conv5_3_vlad_preL2_intra';
paths= localPaths();
load( sprintf('%s%s.mat', paths.ourCNNs, netID), 'net' );
net= relja_simplenn_tidy(net); % potentially upgrate the network to the latest version of NetVLAD / MatConvNet
im= vl_imreadjpeg({which('football.jpg')}); im= im{1}; % slightly convoluted because we need the full image path for `vl_imreadjpeg`, while `imread` is not appropriate - see `help computeRepresentation`
feats= computeRepresentation(net, im, 'useGPU', false); % add `'useGPU', false` if you want to use the CPU
serialAllFeats(net, imPath, imageFns, outputFn);
dbTest= dbTokyo247();
paths= localPaths();
dbFeatFn= sprintf('%s%s_%s_db.bin', paths.outPrefix, netID, dbTest.name);
qFeatFn = sprintf('%s%s_%s_q.bin', paths.outPrefix, netID, dbTest.name);
serialAllFeats(net, dbTest.dbPath, dbTest.dbImageFns, dbFeatFn, 'batchSize', 10); % adjust batchSize depending on your GPU / network size
serialAllFeats(net, dbTest.qPath, dbTest.qImageFns, qFeatFn, 'batchSize', 1); % Tokyo 24/7 query images have different resolutions so batchSize is constrained to 1
[recall, ~, ~, opts]= testFromFn(dbTest, dbFeatFn, qFeatFn);
plot(opts.recallNs, recall, 'ro-'); grid on; xlabel('N'); ylabel('Recall@N'); title(netID, 'Interpreter', 'none');
recall= testFromFn(dbTest, dbFeatFn, qFeatFn, [], 'cropToDim', 256);
