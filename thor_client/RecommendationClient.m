classdef RecommendationClient
    properties
        recommendation_id
        config
        auth_token
    end
    methods
        function obj = RecommendationClient(identifier, config, auth_token)
            obj.recommendation_id = identifier;
            obj.config = config;
            obj.auth_token = auth_token;
        end
        function res = submit_recommendation(obj, value)
            % Submit the returned metric value for a point that was
            % recommended by the Bayesian optimization routine.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST');
            url = base_url('submit_recommendation');
            data = struct('value', value,                                    ...
                'auth_token', obj.auth_token,                                ...
                'recommendation_id', obj.recommendation_id);
            res = webwrite(url, data, options);
        end
    end
end