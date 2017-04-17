classdef ExperimentClient
    properties
        experiment_id
        name
        date
        dims
        auth_token
    end
    methods
        function obj = ExperimentClient(identifier, name, date, dims, auth_token)
            % Initialize parameters of the experiment client object.
            obj.experiment_id = identifier;
            obj.name = name;
            obj.date = date;
            obj.dims = dims;
            obj.auth_token = auth_token;
        end
        function res = submit_observation(obj, config, target)
            % Upload a pairing of a configuration alongside an observed
            % target variable.
            json_config = jsonencode(config);
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST',                                     ...
                'Timeout', 180);
            url = base_url('submit_observation');
            data = struct('auth_token', obj.auth_token,                      ...
                'configuration', json_config,                                ...
                'target', target,                                            ...
                'experiment_id', obj.experiment_id);
            res = webwrite(url, data, options);
        end
        function rec = create_recommendation(obj)
            % Create a recommendation for a point to evaluate next.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST',                                     ...
                'Timeout', 180);
            url = base_url('create_recommendation');
            data = struct('auth_token', obj.auth_token,                      ...
                'experiment_id', obj.experiment_id);
            res = webwrite(url, data, options);
            rec = RecommendationClient(res.id, jsondecode(res.config),       ...
                obj.auth_token);
        end
        function res = best_configuration(obj)
            % Get the configuration of parameters that produced the best
            % value of the object function.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST',                                     ...
                'Timeout', 180);
            url = base_url('best_configuration');
            data = struct('auth_token', obj.auth_token,                      ...
                'experiment_id', obj.experiment_id);
            res = webwrite(url, data, options);
        end
        function pending = pending_recommendations(obj)
            % Query for pending recommendations that have yet to be
            % evaluated.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST',                                     ...
                'Timeout', 180);
            url = base_url('pending_recommendations');
            data = struct('auth_token', obj.auth_token,                      ...
                'experiment_id', obj.experiment_id);
            res = webwrite(url, data, options);
            n_pending = length(res);
            pending = cell(n_pending, 1);
            for i = 1:n_pending
                pending{i} = RecommendationClient(res(i).id,                 ...
                    jsondecode(res(i).config),                               ...
                    obj.auth_token);
            end
        end
    end
end