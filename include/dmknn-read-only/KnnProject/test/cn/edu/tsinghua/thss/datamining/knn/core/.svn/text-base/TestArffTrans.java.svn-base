package cn.edu.tsinghua.thss.datamining.knn.core;
import java.util.Vector;

import cn.edu.tsinghua.thss.datamining.knn.model.Attribute;
import cn.edu.tsinghua.thss.datamining.knn.model.DataSet;
import cn.edu.tsinghua.thss.datamining.knn.model.Instance;


public class TestArffTrans {
	 public static void main(String[] args) {

         ArffTransformer arffTrans=new ArffTransformer("c:/test.arff");
         DataSet ds=arffTrans.getDatasetFromFile();
         Vector<Attribute> features=ds.getFeatures();
         for(int i=0;i<features.size();i++)
        	 System.out.println(features.get(i));
         System.out.println("Dataset size:"+ds.getSize());
         for(Instance instance:ds.getInstances())
        	 System.out.println(instance);
     }


}
