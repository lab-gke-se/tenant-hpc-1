import yaml
import json


# def string_constructor(loader, node):
#     t = string.Template(node.value)
#     value = t.substitute(context)
#     return value


def str_presenter(dumper, data):
    """configures yaml for dumping multiline strings
    Ref: https://stackoverflow.com/questions/8640959/how-can-i-control-what-scalar-form-pyyaml-uses-for-my-data
    """
    if data.count("\n") > 0:  # check for multiline string
        return dumper.represent_scalar("tag:yaml.org,2002:str", data, style="|")
    return dumper.represent_scalar("tag:yaml.org,2002:str", data)


yaml.add_representer(str, str_presenter)
yaml.representer.SafeRepresenter.add_representer(
    str, str_presenter
)  # to use with safe_dump


def read_yaml_file(file_name: str):
    try:
        with open(file_name, encoding="utf-8", mode="r") as yaml_file:
            return yaml.safe_load(yaml_file)
    except FileNotFoundError:
        raise


def read_yaml_file_substitute(file_name: str, context: dict):
    try:
        with open(file_name, encoding="utf-8", mode="r") as yaml_file:
            return yaml.safe_load(yaml_file)
    except FileNotFoundError:
        raise


def write_yaml_file(file_name: str, data: any):
    yaml.add_representer(str, str_presenter)
    yaml.representer.SafeRepresenter.add_representer(
        str, str_presenter
    )  # to use with safe_dum
    with open(file_name, "w") as outfile:
        yaml.dump(data, outfile, default_flow_style=False, sort_keys=False)


def read_json_file(file_name: str):
    try:
        with open(
            file_name,
            encoding="utf-8",
            mode="r",
        ) as json_file:
            return json.load(json_file)
    except FileNotFoundError:
        raise


def write_json_file(file_name: str, data: any):
    try:
        with open(
            path.join(path.dirname(path.abspath(__file__)), file_name), "w"
        ) as file:
            json.dump(data, file, sort_keys=True)
    except:
        raise
