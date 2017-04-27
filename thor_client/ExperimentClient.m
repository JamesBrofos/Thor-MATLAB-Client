classdef ExperimentClient
    % Experiment Client Class
    %
    % This object defines a Thor experiment within the Python environment.
    % In particular, an experiment is defined by its name, the date at
    % which it was created, and the dimensions of the machine learning
    % model. Moreover, an authentication token is required for requesting
    % new parameter configurations, for submitting observations of
    % parameters, for viewing pending parameter configurations and for
    % obtaining the best configuration of parameters that has been
    % evaluated so far.
    %
    %
    % Parameters:
    %     identifier (int): A unique identifier that indicates which experiment
    %         on the server-side is being interacted with by the client.
    %     name (str): A name for the machine learning experiment. Consumers
    %         of the Thor service must have unique experiment names, so
    %         make sure all of your experiments are named different things!
    %     date (datetime): The datetime at which the experiment was created
    %         on the server side.
    %     dims (list of structs): A list of structs describing the
    %         parameter space of the optimization problem. Each dimension
    %         is given a name, a maximum value, a minimum value, and a
    %         dimension type that roughly describes how points are spaced.
    properties
        experiment_id
        name
        date
        dims
        auth_token
    end
    methods
        function obj = ExperimentClient(identifier, name, date, dims, ...
                auth_token)
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
            %
            % Parameters:
            %     config (struct): A struct mapping dimension names to
            %         values indicating the configuration of parameters.
            %     target (float): A number indicating the performance of
            %         this configuration of model parameters.
            % Examples:
            %
            %     This utility is helpful in the event that a machine
            %     learning practitioner already has a few existing
            %     evaluations of the system at given inputs. For instance,
            %     the consumer may have already performed a grid search to
            %     obtain parameter values. Suppose that a particular
            %     experiment has two dimensions named "x" and "y". Then to
            %     upload a configuration to the Thor server, we proceed as
            %     follows:
            %
            %     >> d = struct('x', 1.5, 'y', 3.1);
            %     >> v = f(d.x, d.y);
            %     >> exp.submit_observation(d, v);
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
        function rec = create_recommendation(obj, rand_prob, n_model_iters)
            % Create a recommendation for a point to evaluate next.
            %
            % The create recommendation utility represents the core of the
            % Thor Bayesian optimization software. This function will
            % contact the Thor server and request a new configuration of
            % machine learning parameters that serve the object of
            % maximizing the metric of interest.
            %
            % Parameters:
            %     rand_prob (optional, float): This parameter represents
            %         that a random point in the input space is chosen
            %         instead of selecting a configuration of parameters
            %         using Bayesian optimization. As such, this parameter
            %         can be used to benchmark against random search and
            %         otherwise to perform pure exploration of the
            %         parameter space.
            %     n_model_iters (optional, int): This parameter determines the number
            %         of maximum likelihood random restarts are used to
            %         isolate the maximum of the Gaussian process
            %         likelihood with respect to the kernel parameters.
            %         Setting this to a large value will generally provide
            %         better probabilistic interpolants of the metric as a
            %         function of the model parameters. In large-scale
            %         problems, this parameter instead controls the number
            %         of training iterations used to fit a Bayesian neural
            %         network. In particular, 1,000 times this parameter
            %         epochs are performed.
            %
            % Returns:
            %     RecommendationClient: A recommendation client object
            %         corresponding to the recommended set of parameters.
            if nargin < 3
                % Make the number of model parameters null if it is not
                % provided.
                n_model_iters = string(nan);
            end
            if nargin < 2
                % Make the probability of randomly choosing a configuration
                % to evaluate null if it is not provided.
                rand_prob = string(nan);
            end
            options = weboptions('ContentType', 'json',                      ...
                'MediaType', 'application/json',                             ...
                'RequestMethod', 'POST',                                     ...
                'Timeout', 180);
            url = base_url('create_recommendation');
            data = struct('auth_token', obj.auth_token,                      ...
                'experiment_id', obj.experiment_id,                          ...
                'rand_prob', rand_prob,                                      ...
                'n_model_iters', n_model_iters);
            res = webwrite(url, data, options);
            rec = RecommendationClient(res.id, jsondecode(res.config),       ...
                obj.auth_token);
        end
        function res = best_configuration(obj)
            % Get the configuration of parameters that produced the best
            % value of the object function.
            %
            % Returns:
            %     struct: A struct containing a detailed view of the
            %         configuration of model parameters that produced the
            %         maximal  value of the metric. This includes the date
            %         the observation was created, the value of the metric,
            %         and the configuration itself.
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
            %
            % Sometimes client-side computations may fail for a given input
            % configuration of model parameters, leaving the recommendation
            % in a kind of "limbo" state in which is not being evaluated
            % but still exists. In this case, it can be advantageous for
            % the client to query for such pending observations and to
            % evaluate them. This function returns a list of pending
            % recommendations which can then be evaluated by the client.
            %
            % Returns:
            %     list of RecommendationClient: A list of recommendation
            %         client objects, where each element in the list
            %         corresponds to a pending observation.
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