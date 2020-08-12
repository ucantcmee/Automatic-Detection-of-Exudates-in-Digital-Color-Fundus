function F = asf(I, varargin)

if isempty(ver('images'))
    error('asf:errortoolbox', 'Image Processing toolbox required');
end

error(nargchk(1, 17, nargin, 'struct'));
error(nargoutchk(1, 1, nargout, 'struct'));

if ~isnumeric(I)
    error('asf:inputparameter','a matrix is required in input');
end

% optional parameters
p = createParser('ASF');

p.addOptional('op', 'oc', @(x)ischar(x) && ...
    any(strcmpi(x,{'co','oc','oco','coc','rco','roc','rcoc','roco'})));
p.addOptional('n', 1, @(x)isnumeric(x) && x>=1);
p.addOptional('shape', 'disk', @(x) ischar(x) && ...
    any(strcmpi(x,{'disk','rectangle','square','diamond', ...
                'line','periodicline','octagon'})));
p.addParamValue('s1', 3, @(x)isnumeric(x));
p.addParamValue('s2', [], @(x)isnumeric(x));

% parse and validate all input arguments
p.parse(varargin{:});
p = getvarParser(p);

if ~isnumeric(I)
    error('asf:inputparameter','a matrix is required in input');
end

% optional parameters
p = createParser('ASF');

p.addOptional('op', 'oc', @(x)ischar(x) && ...
    any(strcmpi(x,{'co','oc','oco','coc','rco','roc','rcoc','roco'})));
p.addOptional('n', 1, @(x)isnumeric(x) && x>=1);
p.addOptional('shape', 'disk', @(x) ischar(x) && ...
    any(strcmpi(x,{'disk','rectangle','square','diamond', ...
                'line','periodicline','octagon'})));
p.addParamValue('s1', 3, @(x)isnumeric(x));
p.addParamValue('s2', [], @(x)isnumeric(x));

% parse and validate all input arguments
p.parse(varargin{:});
p = getvarParser(p);

F = asf_base(I, p.n, p.shape, p.op, p.s1, p.s2);
display

if p.disp
    thetitle = 'ASF';
    if p.op(1)=='r', thetitle = [thetitle ' by reconstruction'];  end
    thetitle = [thetitle ' - order: ' p.op(end-1:end)];
    figure, imagesc(rescale(F)), axis image off, title(thetitle);
    if size(I,3)==1,  colormap gray;  end
end
end % end of asf