import tabulate

class ObjectRegistry(object):
    """ Registry of objects by name. """

    def __init__(self, name):

        self._name = name
        self._lookup = dict()

    def help(self):
        table = tabulate.tabulate(
            self._lookup.items(), headers=['Name', self._name.capitalize()]
        )
        help_str = "Valid names are:\n\n{0}".format(table)
        return help_str

    def from_name(self, name):
        """ Returns an instance for the given code. """
        if name not in self._lookup:
            raise ValueError('Unkown name {} in registry'.format(name))
        return self._lookup[name]

    def register(self, name, calendar):
        if name not in self._lookup:
            self._lookup[name] = calendar


