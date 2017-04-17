classdef ThorClient
    properties
        auth_token
    end
    methods
        function obj = ThorClient(auth_token)
            % Initialize the parameters of the Thor API client.
            obj.auth_token = auth_token;
        end
        function exp = create_experiment(obj, name, dimensions, acq_func)
            % Create an experiment.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST');
            url = base_url('create_experiment');
            data = struct('name', name,                                      ...
                'auth_token', obj.auth_token,                                ...
                'acq_func', acq_func,                                        ...
                'dimensions', dimensions);
            res = webwrite(url, data, options);
            exp = ExperimentClient(res.id, res.name, res.date, ...
                res.dimensions, obj.auth_token);
        end
        function exp = experiment_for_name(obj, name)
            % Get an experiment with a given name.
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST');
            url = base_url('experiment_for_name');
            data = struct('name', name,                                      ...
                'auth_token', obj.auth_token);
            res = webwrite(url, data, options);
            exp = ExperimentClient(res.id, res.name, res.date, ...
                res.dimensions, obj.auth_token);
        end
    end
end