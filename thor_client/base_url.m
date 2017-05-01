function ret = base_url(api_endpoint)
% Constructs the URL for an API endpoint for the Thor Server application.
%
% The url that should be used in contact the Thor server. When Thor is deployed
% locally, it make sense to use the localhost designation. On the other hand,
% when deployed remotely, a particular URL needs to be provided.
%
% Parameters:
%     api_endpoint (str): The endpoint to query. This is a string that makes
%         sense for the enpoint (e.g. `create_experiment` for creating an
%         experiment using Thor).
%
% Examples:
%     To send data to the API endpoint to create an experiment, execute:
%
%     >> url = base_url('create_experiment');
%
%     To request a recommendation, the URL is,
%
%     >> url = base_url('create_recommendation');
ret = sprintf('http://aa-lnx01.mitre.org:5000/api/%s/', api_endpoint);
end
