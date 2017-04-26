% Link to the Thor MATLAB client.
addpath(genpath('../../thor_client/'))

% Authenticate with the Thor server.
auth_token = 'YOUR_AUTH_TOKEN';
tc = ThorClient(auth_token);

% Name the experiment.
name = 'Franke Function (MATLAB)';
dims = [
    struct('name', 'x', 'dim_type', 'linear', 'low', 0., 'high', 1.),
    struct('name', 'y', 'dim_type', 'linear', 'low', 0., 'high', 1.)
];
exp = tc.create_experiment(name, dims);

% Main optimization loop.
for i = 1:30
     % Request parameter recommendation.
     rec = exp.create_recommendation();
     c = rec.config;
     % Evaluate the parameter recommendation.
     v = franke(c.x, c.y);
     % Submit the parameter recommendation's value.
     rec.submit_recommendation(v);
end


