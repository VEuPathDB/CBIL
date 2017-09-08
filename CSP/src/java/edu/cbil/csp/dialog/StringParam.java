package edu.cbil.csp.dialog;

import edu.cbil.csp.StringTemplate;

public class StringParam extends Param<String> {

  public StringParam(String name, String descr, String help, StringTemplate st, StringTemplate ht,
      String prompt, boolean optional) {
    super(name, descr, help, st, ht, prompt, optional);
  }

  public StringParam(String name, String descr, String help, StringTemplate template,
      StringTemplate help_template, String prompt, boolean optional, String initial,
      String[] sample_values) {
    super(name, descr, help, template, help_template, prompt, optional, initial, sample_values);
  }

  @Override
  public String convertToValue(String string) {
    return string;
  }

  @Override
  public String convertToString(String value) {
    return value;
  }

  @Override
  public Item copy(String url_subs) {
    StringParam p = copyParam(name);
    p.current_value = this.current_value;
    return p;
  }

  @Override
  public StringParam copyParam(String new_name) {
    return new StringParam(new_name, descr, help, template, help_template, prompt, optional, initial_value, sample_values);
  }
}
