function helperShowLidarCorners(ptCloudFileNames, indices)
%helperShowLidarCorners To visualize lidar features.

pc = pcread(ptCloudFileNames{1});
indices = indices(~cellfun('isempty',indices));
figureH = figure('Position', [0, 0, 640, 480]);
panel = uipanel('Parent',figureH,'Title','Lidar Features');
ax = axes('Parent',panel,'Color',[0,0,0],'Position',[0 0 1 1],'NextPlot','add');
ax.XLim = pc.XLimits;
ax.YLim = pc.YLimits;
ax.ZLim = pc.ZLimits + [-1, 1];
axis(ax,'equal');
zoom on;
scatterH = scatter3(ax, nan, nan, nan, 7, '.');
view(ax,3);
campos([-117.6074  -48.5841   53.3789]);
handle1 = plot3(ax, nan, nan, nan, '*g', 'MarkerSize', 10);
handle2 = plot3(ax, nan, nan, nan, '*r', 'MarkerSize', 10);
handle3 = plot3(ax, nan, nan, nan, '*b', 'MarkerSize', 10);
handle4 = plot3(ax, nan, nan, nan, '*m', 'MarkerSize', 10);
qH1 = quiver3(ax, nan, nan, nan, nan, nan, nan, 'MaxHeadSize', 3, ...
    'Color', 'yellow', 'LineWidth', 3);
qH2 = quiver3(ax, nan, nan, nan, nan, nan, nan, 'MaxHeadSize', 3, ...
    'Color', 'green', 'LineWidth', 3);
qH3 = quiver3(ax, nan, nan, nan, nan, nan, nan, 'MaxHeadSize', 3, ...
    'Color', 'b', 'LineWidth', 3);
qH4 = quiver3(ax, nan, nan, nan, nan, nan, nan, 'MaxHeadSize', 3, ...
    'Color', 'm', 'LineWidth', 3);
qH5 = quiver3(ax, nan, nan, nan, nan, nan, nan, 'MaxHeadSize', 3, ...
    'Color', 'r', 'LineWidth', 3);

numFrames = numel(ptCloudFileNames);
for i = 1:numFrames
    ptCloud = pcread(ptCloudFileNames{i});
    xyzPts = ptCloud.Location;
    % check if the point cloud is organised
    if ~ismatrix(xyzPts)
        x = reshape(xyzPts(:, :, 1), [], 1);
        y = reshape(xyzPts(:, :, 2), [], 1);
        z = reshape(xyzPts(:, :, 3), [], 1);
        xyzPts = [x, y, z];
    else
        x = xyzPts(:, 1);
        y = xyzPts(:, 2);
        z = xyzPts(:, 3);
    end
    
    % Fill magenta color to the input
    ptCloud = pointCloud(xyzPts);
    color = uint8([255*ones(size(ptCloud.Location, 1), 1),...
        zeros(size(ptCloud.Location, 1), 1), 255*ones(size(ptCloud.Location, 1), 1)]);
    
    x = ptCloud.Location(:, 1);
    y = ptCloud.Location(:, 2);
    z = ptCloud.Location(:, 3);
    r = color(:, 1);
    g = color(:, 2);
    b = color(:, 3);
    ptCloud.Color = color;
    
    plane = select(ptCloud, indices{i});
    r(indices{i}) = zeros(plane.Count, 1);
    g(indices{i}) = 255*ones(plane.Count, 1);
    b(indices{i}) = zeros(plane.Count, 1);
    
    % Extract corners of plane
    corner = lidar.internal.calibration.extractLidarCorners(plane, false);
    % Extract plane and edge information
    [edgeDirection, planeParams] = lidar.internal.calibration.computePlaneAndEdgeParameters(corner);
    
    planeSize = plane.Count;
    planeColor = uint8([zeros(planeSize, 1),...
        255*ones(planeSize, 1), zeros(planeSize, 1)]);
    plane.Color = planeColor;
    
    % extract normals
    normal= planeParams(1:3);
    % extract centroids
    centroidLidarFrame = mean(corner);
    % update point cloud
    set(scatterH,'XData',x,'YData',y,'ZData',z, 'CData', [r,g,b]);
    
    % draw normals
    set(qH1, 'XData', centroidLidarFrame(1), 'YData', centroidLidarFrame(2),...
        'ZData', centroidLidarFrame(3), 'UData', normal(1), 'VData',...
        normal(2), 'WData', normal(3));
    
    % draw direction of edges in Lidar Frame
    set(qH2, 'XData', corner(1, 1), 'YData', corner(1, 2), 'ZData',...
        corner(1, 3), 'UData', edgeDirection(1, 1), 'VData', ...
        edgeDirection(1, 2), 'WData', edgeDirection(1, 3));
    
    set(qH3, 'XData', corner(2, 1), 'YData', corner(2, 2), 'ZData',...
        corner(2,3), 'UData', edgeDirection(2, 1), 'VData', ...
        edgeDirection(2, 2), 'WData', edgeDirection(2, 3));
    
    set(qH4, 'XData', corner(3, 1), 'YData', corner(3, 2), 'ZData',...
        corner(3, 3), 'UData', edgeDirection(3, 1), 'VData', ...
        edgeDirection(3, 2), 'WData', edgeDirection(3, 3));
    
    set(qH5, 'XData', corner(4, 1), 'YData', corner(4, 2), 'ZData',...
        corner(4, 3), 'UData', edgeDirection(4, 1), 'VData', ...
        edgeDirection(4, 2), 'WData', edgeDirection(4, 3));
    % draw corners in 3D
    set(handle1,'XData',corner(1,1),'YData',corner(1,2),'ZData',corner(1,3));
    set(handle2,'XData',corner(2,1),'YData',corner(2,2),'ZData',corner(2,3));
    set(handle3,'XData',corner(3,1),'YData',corner(3,2),'ZData',corner(3,3));
    set(handle4,'XData',corner(4,1),'YData',corner(4,2),'ZData',corner(4,3));
    pause(1);
end
end