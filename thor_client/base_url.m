function ret = base_url(api_endpoint)
% ret = sprintf('http://192.168.1.169:5000/api/%s/', api_endpoint);
ret = sprintf('http://aa-lnx01.mitre.org:5000/api/%s/', api_endpoint);
end
