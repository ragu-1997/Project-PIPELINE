from ansible import errors


def listify(f):
    def f_(*args, **kwargs):
        return list(f(*args, **kwargs))
    return f_


@listify
def addresses(group_name, groups, hostvars):
    '''
    Logic copied from http://docs.ansible.com/playbooks_variables.html#magic-variables-and-how-to-access-information-about-other-hosts
    '''
    for host in groups[group_name]:
        yield hostvars[host]['ec2_private_ip_address']


@listify
def map_add(iterable, adder):
    '''
    add `adder` to each in `iterable`
    '''
    for item in iterable:
        yield item + adder


class FilterModule(object):
    '''
    '''

    def filters(self):
        return {
            'addresses': addresses,
            'map_add': map_add,
        }
