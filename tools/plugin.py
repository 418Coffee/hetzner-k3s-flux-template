from typing import Any
import makejinja
import yaml

def to_yaml(value: Any) -> str:
    if isinstance(value, type({}.values)):
        raise Exception("a values map in config.yaml is most likely invalid")
    if isinstance(value, dict) or isinstance(value, list):
        return yaml.dump(value, default_flow_style=False, indent=0)
    return str(value).lower() # hacky

def quote(value: Any) -> str:
    return f'"{str(value)}"'

class Plugin(makejinja.plugin.Plugin):
    def filters(self) -> makejinja.plugin.Filters:
        return [to_yaml, quote]

    def functions(self) -> makejinja.plugin.Functions:
        return []

    def path_filters(self) -> makejinja.plugin.PathFilters:
        return []
