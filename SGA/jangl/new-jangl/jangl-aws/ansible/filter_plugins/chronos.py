class FilterModule(object):
    def filters(self):
        return {
            'chronos_env': self.chronos_env,
        }

    def chronos_env(self, env_dict):
        env = []
        for key, value in env_dict.items():
            env.append('{}={}'.format(key, value))
        return env
