
import java.io.File;
import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.input.SAXBuilder;

/**
 * Created by Manu on 6/11/2018.
 */
public class KanjiParse {

    public static void main(String[] args) {
        File dict = new File("kanjidic2.xml");
        SAXBuilder b = new SAXBuilder();
        List kList = null;
        try {
            Document doc = b.build(dict);
            Element root = doc.getRootElement();
            kList = root.getChildren("character");
        } catch(Exception e) {
            System.out.println(e);
        }

        HashMap<String, HashMap<String, ArrayList<String>>> kanji = new HashMap<>();
        for (Element k : (Iterable<Element>) kList) {
            String kString = k.getChildText("literal");
            HashMap<String, ArrayList<String>> attr = new HashMap<>();

            String grade = k.getChild("misc").getChildText("grade");
            ArrayList<String> gradeL = new ArrayList<>();
            gradeL.add(grade);
            String strokeNum = k.getChild("misc").getChildText("stroke_count");
            ArrayList<String> strokeL = new ArrayList<>();
            strokeL.add(strokeNum);
            String jlpt = k.getChild("misc").getChildText("jlpt");
            ArrayList<String> jlptL = new ArrayList<>();
            jlptL.add(jlpt);
            attr.put("grade", gradeL);
            attr.put("strokeNum", strokeL);
            attr.put("jlpt", jlptL);

            List<Element> elems;
            boolean read = true;
            try {
                elems = k.getChild("reading_meaning").getChild("rmgroup").getChildren();
                ArrayList<String> readings = new ArrayList<>();
                ArrayList<String> meanings = new ArrayList<>();
                for (Element rm : elems) {
                    if (rm.getAttributes().size() > 0 && rm.getAttributes().get(0).getName().equals("r_type")) {
                        String val = rm.getAttributeValue("r_type");
                        if (val.equals("ja_on") || val.equals("ja_kun")) {
                            String reading = rm.getText();
                            readings.add(reading);
                        }
                    } else if (rm.getAttributes().size() == 0) {
                        if (rm.getAttributes().size() == 0) {
                            String meaning = rm.getText();
                            meanings.add(meaning);
                        }
                    }
                }
                attr.put("readings", readings);
                attr.put("meanings", meanings);
            } catch (Exception e) {
                read = false;
            }

            List<Element> nanoriElems;
            boolean named = true;
            try {
                nanoriElems = k.getChild("reading_meaning").getChildren("nanori");
                ArrayList<String> nanori = new ArrayList<>();
                for (Element e : nanoriElems)
                    nanori.add(e.getText());
                attr.put("nanori", nanori);
            } catch (Exception e) {
                named = false;
            }

            if (named || read) {
                kanji.put(kString, attr);
            }

        }

        System.out.println(kanji.size());

        String saveTo = "kanjiMap.dat";
        FileOutputStream fos = null;
        ObjectOutputStream out = null;
        try {
            fos = new FileOutputStream(saveTo);
            out = new ObjectOutputStream(fos);
            out.writeObject(kanji);

            out.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
