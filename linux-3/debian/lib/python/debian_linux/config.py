import os, os.path, re, sys, textwrap

__all__ = [
    'ConfigCoreDump',
    'ConfigCoreHierarchy',
    'ConfigParser',
]

class SchemaItemBoolean(object):
    def __call__(self, i):
        i = i.strip().lower()
        if i in ("true", "1"):
            return True
        if i in ("false", "0"):
            return False
        raise Error

class SchemaItemList(object):
    def __init__(self, type = "\s+"):
        self.type = type

    def __call__(self, i):
        i = i.strip()
        if not i:
            return []
        return [j.strip() for j in re.split(self.type, i)]

class ConfigCore(dict):
    def get_merge(self, section, arch, featureset, flavour, key, default=None):
        temp = []

        if arch and featureset and flavour:
            temp.append(self.get((section, arch, featureset, flavour), {}).get(key))
            temp.append(self.get((section, arch, None, flavour), {}).get(key))
        if arch and featureset:
            temp.append(self.get((section, arch, featureset), {}).get(key))
        if arch:
            temp.append(self.get((section, arch), {}).get(key))
        if featureset:
            temp.append(self.get((section, None, featureset), {}).get(key))
        temp.append(self.get((section,), {}).get(key))

        ret = []

        for i in temp:
            if i is None:
                continue
            elif isinstance(i, (list, tuple)):
                ret.extend(i)
            elif ret:
                # TODO
                return ret
            else:
                return i

        return ret or default

    def merge(self, section, arch = None, featureset = None, flavour = None):
        ret = {}
        ret.update(self.get((section,), {}))
        if featureset:
            ret.update(self.get((section, None, featureset), {}))
        if arch:
            ret.update(self.get((section, arch), {}))
        if arch and featureset:
            ret.update(self.get((section, arch, featureset), {}))
        if arch and featureset and flavour:
            ret.update(self.get((section, arch, None, flavour), {}))
            ret.update(self.get((section, arch, featureset, flavour), {}))
        return ret

    def dump(self, fp):
        sections = self.keys()
        sections.sort()
        for section in sections:
            fp.write('[%r]\n' % (section,))
            items = self[section]
            items_keys = items.keys()
            items_keys.sort()
            for item in items:
                fp.write('%s: %r\n' % (item, items[item]))
            fp.write('\n')

class ConfigCoreDump(ConfigCore):
    def __init__(self, config = None, fp = None):
        super(ConfigCoreDump, self).__init__(self)
        if config is not None:
            self.update(config)
        if fp is not None:
            from ConfigParser import RawConfigParser
            config = RawConfigParser()
            config.readfp(fp)
            for section in config.sections():
                section_real = eval(section)
                data = {}
                for key, value in config.items(section):
                    value_real = eval(value)
                    data[key] = value_real
                self[section_real] = data

class ConfigCoreHierarchy(ConfigCore):
    config_name = "defines"

    schemas = {
        'abi': {
            'ignore-changes': SchemaItemList(),
        },
        'base': {
            'arches': SchemaItemList(),
            'enabled': SchemaItemBoolean(),
            'featuresets': SchemaItemList(),
            'flavours': SchemaItemList(),
            'modules': SchemaItemBoolean(),
        },
        'build': {},
        'description': {
            'parts': SchemaItemList(),
        },
        'image': {
            'bootloaders': SchemaItemList(),
            'configs': SchemaItemList(),
            'initramfs': SchemaItemBoolean(),
            'initramfs-generators': SchemaItemList(),
        },
        'image-dbg': {
            'enabled': SchemaItemBoolean(),
        },
        'relations': {
        },
        'xen': {
            'dom0-support': SchemaItemBoolean(),
            'flavours': SchemaItemList(),
            'versions': SchemaItemList(),
        }
    }

    def __init__(self, dirs = []):
        super(ConfigCoreHierarchy, self).__init__()
        self._dirs = dirs
        self._read_base()

    def _read_arch(self, arch):
        config = ConfigParser(self.schemas)
        config.read(self.get_files("%s/%s" % (arch, self.config_name)))

        featuresets = config['base',].get('featuresets', [])
        flavours = config['base',].get('flavours', [])

        for section in iter(config):
            if section[0] in featuresets:
                real = (section[-1], arch, section[0])
            elif len(section) > 1:
                real = (section[-1], arch, None) + section[:-1]
            else:
                real = (section[-1], arch) + section[:-1]
            s = self.get(real, {})
            s.update(config[section])
            self[tuple(real)] = s

        for featureset in featuresets:
            self._read_arch_featureset(arch, featureset)

        if flavours:
            base = self['base', arch]
            featuresets.insert(0, 'none')
            base['featuresets'] = featuresets
            del base['flavours']
            self['base', arch] = base
            self['base', arch, 'none'] = {'flavours': flavours, 'implicit-flavour': True}

    def _read_arch_featureset(self, arch, featureset):
        config = ConfigParser(self.schemas)
        config.read(self.get_files("%s/%s/%s" % (arch, featureset, self.config_name)))

        flavours = config['base',].get('flavours', [])

        for section in iter(config):
            real = (section[-1], arch, featureset) + section[:-1]
            s = self.get(real, {})
            s.update(config[section])
            self[tuple(real)] = s

    def _read_base(self):
        config = ConfigParser(self.schemas)
        config.read(self.get_files(self.config_name))

        arches = config['base',]['arches']
        featuresets = config['base',].get('featuresets', [])

        for section in iter(config):
            if section[0].startswith('featureset-'):
                real = (section[-1], None, section[0].lstrip('featureset-'))
            else:
                real = (section[-1],) + section[1:]
            self[real] = config[section]

        for arch in arches:
            self._read_arch(arch)
        for featureset in featuresets:
            self._read_featureset(featureset)

    def _read_featureset(self, featureset):
        config = ConfigParser(self.schemas)
        config.read(self.get_files("featureset-%s/%s" % (featureset, self.config_name)))

        for section in iter(config):
            real = (section[-1], None, featureset)
            s = self.get(real, {})
            s.update(config[section])
            self[real] = s

    def get_files(self, name):
        return [os.path.join(i, name) for i in self._dirs if i]

class ConfigParser(object):
    __slots__ = '_config', 'schemas'

    def __init__(self, schemas):
        self.schemas = schemas

        from ConfigParser import RawConfigParser
        self._config = config = RawConfigParser()

    def __getitem__(self, key):
        return self._convert()[key]

    def __iter__(self):
        return iter(self._convert())

    def __str__(self):
        return '<%s(%s)>' % (self.__class__.__name__, self._convert())

    def _convert(self):
        ret = {}
        for section in self._config.sections():
            data = {}
            for key, value in self._config.items(section):
                data[key] = value
            s1 = section.split('_')
            if s1[-1] in self.schemas:
                ret[tuple(s1)] = self.SectionSchema(data, self.schemas[s1[-1]])
            else:
                ret[(section,)] = self.Section(data)
        return ret

    def keys(self):
        return self._convert().keys()

    def read(self, data):
        return self._config.read(data)

    class Section(dict):
        def __init__(self, data):
            super(ConfigParser.Section, self).__init__(data)

    class SectionSchema(Section):
        __slots__ = ()

        def __init__(self, data, schema):
            for key in data.keys():
                try:
                    data[key] = schema[key](data[key])
                except KeyError: pass
            super(ConfigParser.SectionSchema, self).__init__(data)

if __name__ == '__main__':
    import sys
    config = ConfigCoreHierarchy(['debian/config'])
    sections = config.keys()
    sections.sort()
    for section in sections:
        print "[%s]" % (section,)
        items = config[section]
        items_keys = items.keys()
        items_keys.sort()
        for item in items:
            print "%s: %s" % (item, items[item])
        print

