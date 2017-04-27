classdef RecommendationClient
    % Thor Recommendation Client Class
    %
    % The purpose of this class is to provide an interface for interacting
    % with suggestions provided by the Thor API. In particular, once a
    % recommendation is received, it will be evaluated by the client's
    % local computer. After this, its value as a configuration will be
    % transmitted back to the Thor server.
    %
    % Parameters:
    %     identifier (int): An integer identifier for this recommendation.
    %         This allows the Thor server to identify which recommendation was 
    %         associated with a given value of the metric on the client side.
    %     config (struct): A struct containing the recommended parameter
    %         values for each dimension of the optimization problem. 
    %     auth_token (str): String containing a user's specific API key
    %         provided by the Thor server.
    %
    % Examples:
    %     The recommedation client sends metric values back to the Thor server
    %     using a convenient API interface.
    %
    %    >> exp = tc.experiment_for_name('YOUR_EXPERIMENT_NAME');
    %    >> rec = exp.create_recommendation();
    %    >> rec.submit_recommendation(1.0);
    properties
        recommendation_id
        config
        auth_token
    end
    methods
        function obj = RecommendationClient(identifier, config, auth_token)
            % Initialize parameters of the Thor recommendation client
            % object.
            obj.recommendation_id = identifier;
            obj.config = config;
            obj.auth_token = auth_token;
        end
        function res = submit_recommendation(obj, value)
            % Submit the returned metric value for a point that was
            % recommended by the Bayesian optimization routine.
            %
            % Parameters:
            %     value (float): A number indicating the performance of this
            %         configuration of model parameters.
            %
            % Returns:
            %     struct: A struct containing the recommendation identifier
            %     and a boolean indicator that the recommendation was
            %     submitted.
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
