function bufferCount = foundOnBufferLayer( layerA, layerN )
%%%Layer A is bufferStruct(1).a
%%%if bufferStruct(1).a is a matrix
[p,q] = size(layerA);
[r,s] = size(layerN);
colLayerA = p;
colLayerN = r;
bufferCount = zeros(1,p);
distanceBetweenVessels = 250;
%LayerA is a Matrix

%k index in buffer.a
for k=1:colLayerA
    isFirstLayer = false;
    for m=1:colLayerN
        
        %
        vesselA = layerA(k,:);
        vesselN = layerN(m,:);
        %search if A(k) and N(m) vessels are close
        vesselAX = vesselA(1)+vesselA(3)/2;
        vesselAY = vesselA(2)+vesselA(4)/2;
        vesselNX = vesselN(1)+vesselN(3)/2;
        vesselNY = vesselN(2)+vesselN(4)/2;
        distBetweenVessels = [vesselAX, vesselAY; ...
            vesselNX, vesselNY];
        pdistBetweenVessels = pdist(distBetweenVessels, 'euclidean');
        %                    disp('dist');
        %                    disp(pdistBetweenVessels);
        
        
        
        if pdistBetweenVessels < distanceBetweenVessels
            
            isFirstLayer = true;
            
            %disp('entrou');
            %remove inds k and m from inds
            
            %ind = [1 4 7] ; % indices to be removed
            %A(ind) = []; % remove
            
            %array_inds array to put vessels that are too close
            %to other vessels
            
            if isFirstLayer == true
                bufferCount(k) = bufferCount(k) + 1;
            end
        end
    end
end

end