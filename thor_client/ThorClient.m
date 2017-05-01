classdef ThorClient
    % Thor Client Class
    %
    % The purpose of this module is to allow MATLAB users to utilize the Thor
    % utility for Bayesian optimization of machine learning systems. This module
    % in particular is intended to properly authenticate with Thor and to create
    % experiments.
    %
    % Parameters:
    %     auth_token (str): String containing a user's specific API key provided
    %         by the Thor server. This is used to authenticate with the Thor
    %         server as a handshake that these experiments belong to a user and
    %         can be viewed and edited by them.
    %
    % Examples:
    %     The Thor Client can be used to create experiments as follows:
    %
    %     >> tc = ThorClient('YOUR_API_KEY');
    %     >> dims = struct('name', 'x', 'dim_type', 'linear', 'low', 0., 'high', 1.);
    %     >> exp = tc.create_experiment('YOUR_EXPERIMENT_NAME', dims);
    %
    %     Alternatively, the Thor Client can be used to query for existing
    %     experiments.
    %
    %     >> exp = tc.experiment_for_name('YOUR_EXISTING_EXPERIMENT');
    properties
        auth_token
    end
    methods
        function obj = ThorClient(auth_token)
            % Initialize the parameters of the Thor API client.
            obj.auth_token = auth_token;
        end
        function exp = create_experiment(obj, name, dimensions, acq_func,    ...
                                         overwrite)
            % Create an experiment.
            %
            % Parameters:
            %     name (str): String containing the name of the experiment
            %         to create.
            %     dimensions (list of structs): A list of structs that specify
            %         the hyperparameters of the machine learning system. Each
            %         dimension must specify the following four properties:
            %             1. The name of the dimension, which key "name".
            %             2. The type of dimension to create, which must be
            %                one of "linear", "exponential", "logarithmic", or
            %                "integer". This is specified by the key
            %                "dim_type".
            %             3. The minimum value of the dimension, specified
            %                by the key "low".
            %             4. The maximum value of the dimension, specified by
            %                the key "high".
            %     acq_func (optional, str): A string containing the name of the
            %         acquisition function to use. This can be one of "hedge",
            %         "upper_confidence_bound", "expected_improvement", or
            %         "improvement_probability".
            %     overwrite (optional, bool): An indicator variable which will
            %         overwrite existing experiments with the given name if
            %         they already exist on Thor Server.
            % Returns:
            %     ExperimentClient: A corresponding experiment with the
            %         provided name and dimensions.
            if nargin < 5
                % By default do not overwrite experiments if they exist on the
                % Thor server.
                overwrite = false;
            end
            if nargin < 4
                % Make the specification of the acquisition function an
                % optional parameter that defaults to the hedging strategy.
                acq_func = 'hedge';
            end
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST');
            url = base_url('create_experiment');
            data = struct('name', name,                                      ...
                'auth_token', obj.auth_token,                                ...
                'acq_func', acq_func,                                        ...
                'overwrite', overwrite,                                      ...
                'dimensions', dimensions);
            res = webwrite(url, data, options);
            exp = ExperimentClient(res.id, res.name, res.date, ...
                res.dimensions, obj.auth_token);
        end
        function exp = experiment_for_name(obj, name)
            % Get an experiment with a given name.
            %
            % Parameters:
            %     name (str): String containing the name of the experiment
            %         that should be obtained.
            % Returns:
            %     ExperimentClient: A corresponding experiment with the
            %         provided name. The object returned by this method is
            %         identical in functionality to the object that is
            %         returned by the function "create_experiment".
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST');
            url = base_url('experiment_for_name');
            data = struct('name', name,                                      ...
                'auth_token', obj.auth_token);
            res = webwrite(url, data, options);
            exp = ExperimentClient(res.id, res.name, res.date,               ...
                res.dimensions, obj.auth_token);
        end
    end
end
